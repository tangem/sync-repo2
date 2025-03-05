//
//  KaspaNetworkProvider.swift
//  BlockchainSdk
//
//  Created by Andrey Chukavin on 10.03.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import TangemNetworkUtils

/// https://api.kaspa.org/docs#/
class KaspaNetworkProvider: HostProvider {
    var host: String {
        url.hostOrUnknown
    }

    private let url: URL
    private let provider: NetworkProvider<KaspaTarget>

    init(url: URL, networkConfiguration: NetworkProviderConfiguration) {
        self.url = url
        provider = NetworkProvider<KaspaTarget>(configuration: networkConfiguration)
    }

    func currentBlueScore() -> AnyPublisher<KaspaBlueScoreResponse, Error> {
        requestPublisher(for: .blueScore)
    }

    func balance(address: String) -> AnyPublisher<KaspaBalanceResponse, Error> {
        requestPublisher(for: .balance(address: address))
    }

    func utxos(address: String) -> AnyPublisher<[KaspaUnspentOutputResponse], Error> {
        requestPublisher(for: .utxos(address: address))
    }

    func send(transaction: KaspaTransactionRequest) -> AnyPublisher<KaspaTransactionResponse, Error> {
        requestPublisher(for: .transactions(transaction: transaction))
    }

    func transactionInfo(hash: String) -> AnyPublisher<KaspaTransactionInfoResponse, Error> {
        requestPublisher(for: .transaction(hash: hash))
    }

    func mass(data: KaspaTransactionData) -> AnyPublisher<KaspaMassResponse, Error> {
        requestPublisher(for: .mass(data: data))
    }

    func feeEstimate() -> AnyPublisher<KaspaFeeEstimateResponse, Error> {
        requestPublisher(for: .feeEstimate)
    }
}

// MARK: - UTXONetworkProvider

extension KaspaNetworkProvider: UTXONetworkProvider {
    func getUnspentOutputs(address: String) -> AnyPublisher<[UnspentOutput], any Error> {
        requestPublisher(for: .utxos(address: address))
            .withWeakCaptureOf(self)
            .map { $0.mapToUnspentOutputs(outputs: $1) }
            .eraseToAnyPublisher()
    }

    func getTransactionInfo(hash: String, address: String) -> AnyPublisher<TransactionRecord, any Error> {
        requestPublisher(for: .transaction(hash: address))
        .withWeakCaptureOf(self)
        .tryMap { try $0.mapToTransactionRecord(transaction: $1, address: address) }
        .eraseToAnyPublisher()
    }

    func getFee() -> AnyPublisher<KaspaDTO.EstimateFee.Response, any Error> {
        requestPublisher(for: .feeEstimate)
    }

    func send(transaction: KaspaTransactionRequest) -> AnyPublisher<TransactionSendResult, any Error> {
        requestPublisher(for: .transactions(transaction: transaction))
            .withWeakCaptureOf(self)
            .map { $0.mapToTransactionSendResult(transaction: $1) }
            .eraseToAnyPublisher()
    }
}

// MARK: - Private

private extension KaspaNetworkProvider {
    func requestPublisher<T: Decodable>(for request: KaspaTarget.Request) -> AnyPublisher<T, Error> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return provider.requestPublisher(KaspaTarget(request: request, baseURL: url))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(T.self, using: decoder)
            .mapError { moyaError in
                if case .objectMapping = moyaError {
                    return WalletError.failedToParseNetworkResponse()
                }
                return moyaError
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Mapping

private extension KaspaNetworkProvider {
    func mapToUnspentOutputs(outputs: [KaspaDTO.UTXO.Response]) -> [UnspentOutput] {
        outputs.compactMap { output in
            Decimal(stringValue: output.utxoEntry.amount).map { amount in
                UnspentOutput(
                    blockId: output.utxoEntry.blockDaaScore.flatMap { Int($0) } ?? -1,
                    hash: output.outpoint.transactionId,
                    index: output.outpoint.index,
                    amount: amount.uint64Value
                )
            }
        }
    }

    func mapToTransactionRecord(
        transaction: KaspaDTO.TransactionInfo.Response,
        address: String
    ) throws -> TransactionRecord {
        try KaspaTransactionRecordMapper(blockchain: .kaspa(testnet: false))
            .mapToTransactionRecord(transaction: transaction, address: address)
    }

    func mapToTransactionSendResult(transaction: KaspaDTO.Send.Response) -> TransactionSendResult {
        TransactionSendResult(hash: transaction.transactionId)
    }
}
