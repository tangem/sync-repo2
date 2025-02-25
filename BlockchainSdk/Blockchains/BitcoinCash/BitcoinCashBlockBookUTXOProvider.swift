//
//  BitcoinCashNowNodesNetworkProvider.swift
//  BlockchainSdk
//
//  Created by Dmitry Fedorov on 08.02.2024.
//

import Foundation
import Combine

/// Adapter for existing BlockBookUTXOProvider
final class BitcoinCashBlockBookUTXOProvider: BitcoinNetworkProvider {
    private let blockBookUTXOProvider: BlockBookUTXOProvider
    private let bitcoinCashAddressService: BitcoinCashAddressService

    init(blockBookUTXOProvider: BlockBookUTXOProvider, bitcoinCashAddressService: BitcoinCashAddressService) {
        self.blockBookUTXOProvider = blockBookUTXOProvider
        self.bitcoinCashAddressService = bitcoinCashAddressService
    }

    var host: String {
        blockBookUTXOProvider.host
    }

    var supportsTransactionPush: Bool {
        blockBookUTXOProvider.supportsTransactionPush
    }

    func getInfo(address: String) -> AnyPublisher<BitcoinResponse, Error> {
        blockBookUTXOProvider.getInfo(address: addAddressPrefixIfNeeded(address))
    }

    func getFee() -> AnyPublisher<BitcoinFee, Error> {
        blockBookUTXOProvider
            .rpcCall(
                method: "estimatefee",
                params: AnyEncodable([Int]()),
                responseType: NodeEstimateFeeResponse.self
            )
            .tryMap { [weak self] response in
                guard let self else {
                    throw WalletError.empty
                }

                return try blockBookUTXOProvider.convertFeeRate(response.result.get().result)
            }.map { fee in
                // fee for BCH is constant
                BitcoinFee(minimalSatoshiPerByte: fee, normalSatoshiPerByte: fee, prioritySatoshiPerByte: fee)
            }
            .eraseToAnyPublisher()
    }

    func send(transaction: String) -> AnyPublisher<String, Error> {
        blockBookUTXOProvider
            .rpcCall(
                method: "sendrawtransaction",
                params: AnyEncodable([transaction]),
                responseType: SendResponse.self
            )
            .tryMap { try $0.result.get().result }
            .eraseToAnyPublisher()
    }

    private func addAddressPrefixIfNeeded(_ address: String) -> String {
        if bitcoinCashAddressService.isLegacy(address) {
            return address
        } else {
            let prefix = "bitcoincash:"
            return address.hasPrefix(prefix) ? address : prefix + address
        }
    }
}
