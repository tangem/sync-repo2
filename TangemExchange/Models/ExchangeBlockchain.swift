//
//  ExchangeBlockchain.swift
//  Tangem
//
//  Created by Pavel Grechikhin.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

public enum ExchangeBlockchain: Hashable, CaseIterable {
    case ethereum
    case bsc
    case polygon
    case optimism
    case arbitrum
    case gnosis
    case avalanche
    case fantom
    case klayth
    case aurora

    public init?(networkId: String) {
        if let blockchain = ExchangeBlockchain.allCases.first(where: { $0.networkId == networkId }) {
            self = blockchain
            return
        }

        return nil
    }

    public var chainId: Int {
        switch self {
        case .ethereum: return 1
        case .bsc: return 56
        case .polygon: return 137
        case .optimism: return 10
        case .arbitrum: return 42161
        case .gnosis: return 100
        case .avalanche: return 43114
        case .fantom: return 250
        case .klayth: return 8217
        case .aurora: return 1313161554
        }
    }

    public var decimalCount: Int {
        switch self {
        case .ethereum, .bsc, .polygon, .avalanche, .fantom, .arbitrum, .gnosis, .optimism, .klayth, .aurora:
            return 18
        }
    }

    public var symbol: String {
        switch self {
        case .ethereum, .arbitrum, .optimism, .aurora: return "ETH"
        case .bsc: return "BNB"
        case .polygon: return "MATIC"
        case .avalanche: return "AVAX"
        case .fantom: return "FTM"
        case .gnosis: return "xDAI"
        case .klayth: return "KLAY"
        }
    }

    /// Uses for build icon url
    public var id: String {
        switch self {
        case .ethereum: return "ethereum"
        case .bsc: return "binancecoin"
        case .polygon: return "matic-network"
        case .avalanche: return "avalanche-2"
        case .fantom: return "fantom"
        case .arbitrum: return "arbitrum-one"
        case .gnosis: return "xdai"
        case .optimism: return "optimistic-ethereum"
        case .klayth:
            assertionFailure("Unimplemented")
            return ""
        case .aurora:
            assertionFailure("Unimplemented")
            return ""
        }
    }

    /// Uses for load tokens
    public var networkId: String {
        switch self {
        case .ethereum: return "ethereum"
        case .bsc: return "binance-smart-chain"
        case .polygon: return "polygon-pos"
        case .avalanche: return "avalanche"
        case .fantom: return "fantom"
        case .arbitrum: return "arbitrum-one"
        case .gnosis: return "xdai"
        case .optimism: return "optimistic-ethereum"
        case .klayth: return ""
        case .aurora: return ""
        }
    }

    public func getExploreURL(for address: String, contractAddress: String? = nil) -> URL? {
        switch self {
        case .ethereum:
            if let contractAddress {
                return URL(string: "https://etherscan.io/token/\(contractAddress)?a=\(address)")
            }

            return URL(string: "https://etherscan.io/address/\(address)")!
        case .bsc:
            return URL(string: "https://bscscan.com/address/\(address)")!
        case .polygon:
            return URL(string: "https://polygonscan.com/address/\(address)")!
        case .avalanche:
            return URL(string: "https://snowtrace.io/address/\(address)")!
        case .fantom:
            return URL(string: "https://ftmscan.com/address/\(address)")!
        case .arbitrum:
            return URL(string: "https://arbiscan.io/address/\(address)")!
        case .gnosis:
            return URL(string: "https://blockscout.com/xdai/mainnet/address/\(address)")!
        case .optimism:
            return URL(string: "https://optimistic.etherscan.io/address/\(address)")!
        case .klayth, .aurora:
            return nil
        }
    }
}

public extension ExchangeBlockchain {
    func convertToWEI(value: Decimal) -> Decimal {
        let decimalValue = pow(10, decimalCount)
        return value * decimalValue
    }

    func convertFromWEI(value: Decimal) -> Decimal {
        let decimalValue = pow(10, decimalCount)
        return value / decimalValue
    }
}
