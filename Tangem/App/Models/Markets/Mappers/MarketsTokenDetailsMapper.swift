//
//  MarketsTokenDetailsMapper.swift
//  Tangem
//
//  Created by skibinalexander on 03.07.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk

struct MarketsTokenDetailsMapper {
    let supportedBlockchains: Set<Blockchain>

    private let tokenItemMapper: TokenItemMapper
    private let l2Blockchains = SupportedBlockchains.l2Blockchains

    init(supportedBlockchains: Set<Blockchain>) {
        self.supportedBlockchains = supportedBlockchains
        tokenItemMapper = TokenItemMapper(supportedBlockchains: supportedBlockchains)
    }

    func map(response: MarketsDTO.Coins.Response) throws -> MarketsTokenDetailsModel {
        var networks = response.networks ?? []

        // add l2 networks
        if response.id == Blockchain.ethereum(testnet: false).coinId {
            let l2Items = l2Blockchains.map {
                return NetworkModel(networkId: $0.networkId, contractAddress: nil, decimalCount: nil)
            }

            networks.append(contentsOf: l2Items)
        }

        return MarketsTokenDetailsModel(
            id: response.id,
            name: response.name,
            symbol: response.symbol,
            isActive: response.active,
            currentPrice: response.currentPrice,
            shortDescription: response.shortDescription,
            fullDescription: response.fullDescription,
            numberOfExchangesListedOn: response.exchangesAmount,
            priceChangePercentage: try mapPriceChangePercentage(response: response),
            insights: .init(dto: response.insights),
            metrics: response.metrics,
            securityScore: mapSecurityScore(response: response),
            pricePerformance: mapPricePerformance(response: response),
            links: response.links,
            availableNetworks: networks
        )
    }

    // MARK: - Private Implementation

    private func mapPriceChangePercentage(response: MarketsDTO.Coins.Response) throws -> [String: Decimal] {
        // We need to specify that our target type is Decimal, otherwise it will be Decimal?
        guard let allTimeValue = response.priceChangePercentage[MarketsPriceIntervalType.all.rawValue] as? Decimal else {
            throw MapperError.missingAllTimePriceChangeValue
        }

        return MarketsPriceIntervalType.allCases.reduce(into: [:]) {
            let key = $1.rawValue
            // We need to specify that our target type is Decimal, otherwise it will be Decimal?
            $0[key] = (response.priceChangePercentage[key] as? Decimal) ?? allTimeValue
        }
    }

    private func mapPricePerformance(response: MarketsDTO.Coins.Response) -> [MarketsPriceIntervalType: MarketsPricePerformanceData]? {
        return response.pricePerformance?.reduce(into: [:]) { partialResult, pair in
            guard let intervalType = MarketsPriceIntervalType(rawValue: pair.key) else {
                return
            }

            partialResult[intervalType] = pair.value
        }
    }

    private func mapSecurityScore(response: MarketsDTO.Coins.Response) -> MarketsTokenDetailsSecurityScore? {
        guard
            let securityData = response.securityData,
            let totalSecurityScore = securityData.totalSecurityScore,
            let providerData = securityData.providerData?.nilIfEmpty // `SecurityData` DTO with an empty `providerData` field is invalid
        else {
            return nil
        }

        return MarketsTokenDetailsSecurityScore(
            securityScore: totalSecurityScore,
            providers: providerData.map { provider in
                return .init(
                    id: provider.providerId,
                    name: provider.providerName,
                    securityScore: provider.securityScore,
                    auditDate: provider.lastAuditDate,
                    auditURL: provider.link
                )
            }
        )
    }
}

extension MarketsTokenDetailsMapper {
    enum MapperError: Error {
        case missingAllTimePriceChangeValue
    }
}
