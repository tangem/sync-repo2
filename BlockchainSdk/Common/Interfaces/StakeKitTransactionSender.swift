//
//  StakeKitTransactionSender.swift
//  BlockchainSdk
//
//  Created by Sergey Balashov on 02.09.2024.
//

import Foundation
import TangemSdk

public protocol StakeKitTransactionSender {
    /// Return stream with tx which was sent one by one
    /// If catch error stream will be stopped
    /// In case when manager already implemented the `StakeKitTransactionSenderProvider` method will be not required
    func sendStakeKit(transactions: [StakeKitTransaction], signer: TransactionSigner, delay second: UInt64?) -> AsyncThrowingStream<StakeKitTransactionSendResult, Error>
}

protocol StakeKitTransactionSenderProvider {
    associatedtype RawTransaction

    func prepareDataForSign(transaction: StakeKitTransaction) throws -> Data
    func prepareDataForSend(transaction: StakeKitTransaction, signature: SignatureInfo) throws -> RawTransaction
    func broadcast(transaction: StakeKitTransaction, rawTransaction: RawTransaction) async throws -> String
    func buildRawTransactions(
        from transactions: [StakeKitTransaction],
        signer: TransactionSigner
    ) async throws -> [RawTransaction]
}

extension StakeKitTransactionSenderProvider {
//    func prepareDataForSend(transaction: StakeKitTransaction, signatures: [SignatureInfo]) throws -> RawTransaction {
//        guard let signature = signatures.first else { throw WalletError.empty }
//        return try prepareDataForSend(transaction: transaction, signature: signature)
//    }
}

protocol StakeKitMultiSignatureTransactionSenderProvider: StakeKitTransactionSenderProvider {
    func prepareDataForSend(transaction: StakeKitTransaction, signatures: [SignatureInfo]) throws -> RawTransaction
}

extension StakeKitMultiSignatureTransactionSenderProvider {
    func prepareDataForSend(transaction: StakeKitTransaction, signature: SignatureInfo) throws -> RawTransaction {
        try prepareDataForSend(transaction: transaction, signatures: [signature])
    }
}

// MARK: - Common implementation for StakeKitTransactionSenderProvider

extension StakeKitTransactionSender where Self: StakeKitTransactionSenderProvider, Self: WalletProvider, RawTransaction: CustomStringConvertible {
    func sendStakeKit(transactions: [StakeKitTransaction], signer: TransactionSigner, delay second: UInt64?) -> AsyncThrowingStream<StakeKitTransactionSendResult, Error> {
        .init { [weak self] continuation in
            let task = Task { [weak self] in
                guard let self else {
                    continuation.finish()
                    return
                }

                do {
                    let rawTransactions = try await buildRawTransactions(from: transactions, signer: signer)

                    _ = try await withThrowingTaskGroup(of: (TransactionSendResult, StakeKitTransaction).self) { group in
                        var results = [TransactionSendResult]()
                        for (transaction, rawTransaction) in zip(transactions, rawTransactions) {


                            group.addTask {
                                try Task.checkCancellation()
                                let result: TransactionSendResult = try await self.broadcast(
                                    transaction: transaction,
                                    rawTransaction: rawTransaction
                                )
                                try Task.checkCancellation()
                                return (result, transaction)
                            }

                            if transactions.count > 1, let second {
                                // Wait for the current task to complete before adding the next one
                                guard let result = try await group.next() else { continue }

                                results.append(result.0)
                                continuation.yield(.init(transaction: result.1, result: result.0))
                                // temporary code, will be removed as part of transition to transaction status tracking
                                let delay = result.1.type == .split ? 20 : second
                                try await Task.sleep(nanoseconds: delay * NSEC_PER_SEC)
                            }
                        }

                        for try await result in group where !results.contains(result.0) {
                            continuation.yield(.init(transaction: result.1, result: result.0))
                        }
                        return []
                    }

                    continuation.finish()

                } catch {
                    Log.log("\(self) catch \(error) when sent staking transaction")
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { termination in
                task.cancel()
            }
        }
    }

    /// Convenience method with adding the `PendingTransaction` to the wallet  and `SendTxError` mapping
    private func broadcast(transaction: StakeKitTransaction, rawTransaction: RawTransaction) async throws -> TransactionSendResult {
        do {
            let hash: String = try await broadcast(transaction: transaction, rawTransaction: rawTransaction)
            let mapper = PendingTransactionRecordMapper()
            let record = mapper.mapToPendingTransactionRecord(
                stakeKitTransaction: transaction,
                source: wallet.defaultAddress.value,
                hash: hash
            )

            await addPendingTransaction(record)

            return TransactionSendResult(hash: hash)
        } catch {
            throw SendTxErrorFactory().make(error: error, with: rawTransaction.description)
        }
    }

    @MainActor
    private func addPendingTransaction(_ record: PendingTransactionRecord) {
        wallet.addPendingTransaction(record)
    }

    func buildRawTransactions(
        from transactions: [StakeKitTransaction],
        signer: TransactionSigner
    ) async throws -> [RawTransaction] {
        let preparedHashes = try transactions.map { try self.prepareDataForSign(transaction: $0) }
        let signatures: [SignatureInfo] = try await signer.sign(
            hashes: preparedHashes,
            walletPublicKey: wallet.publicKey
        ).async()

        return try zip(transactions, signatures).map { transaction, signature in
            try prepareDataForSend(transaction: transaction, signature: signature)
        }
    }
}
