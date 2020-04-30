//
//  CardanoWalletManager.swift
//  BlockchainSdk
//
//  Created by Alexander Osokin on 08.04.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import RxSwift
import Combine

enum CardanoError: Error {
    case noUnspents
    case failedToBuildHash
    case failedToBuildTransaction
    case failedToMapNetworkResponse
    case failedToCalculateTxSize
}

class CardanoWalletManager: WalletManager {
    var txBuilder: CardanoTransactionBuilder!
    var networkService: CardanoNetworkService!
    
    override func update(completion: @escaping (Result<Wallet, Error>)-> Void) {//check it
        requestDisposable = networkService
            .getInfo(address: wallet.address)
            .subscribe(onSuccess: {[unowned self] response in
                self.updateWallet(with: response)
                completion(.success(self.wallet))
                }, onError: {error in
                    completion(.failure(error))
            })
    }
    
    private func updateWallet(with response: (AdaliteBalanceResponse,[AdaliteUnspentOutput])) {
        wallet.add(coinValue: response.0.balance)
        txBuilder.unspentOutputs = response.1
        
        wallet.transactions = wallet.transactions.compactMap { pendingTx in
            if let pendingTxHash = pendingTx.hash {
                if response.0.transactionList.contains(pendingTxHash) {
                    return nil
                }
            }
            return pendingTx
        }
    }
}

@available(iOS 13.0, *)
extension CardanoWalletManager: TransactionSender {
    func send(_ transaction: Transaction, signer: TransactionSigner) -> AnyPublisher<Bool, Error> {
        guard let walletAmount = wallet.amounts[.coin]?.value,
            let hashes = txBuilder.buildForSign(transaction: transaction, walletAmount: walletAmount) else {
                return Fail(error: CardanoError.failedToBuildHash).eraseToAnyPublisher()
        }
        
        return signer.sign(hashes: [hashes], cardId: cardId)
            .tryMap {[unowned self] response -> (tx: Data, hash: String) in
                guard let walletAmount = self.wallet.amounts[.coin]?.value, let tx = self.txBuilder.buildForSend(transaction: transaction, walletAmount: walletAmount, signature: response.signature) else {
                    throw CardanoError.failedToBuildTransaction
                }
                return tx
        }
        .flatMap {[unowned self] builderResponse in
            self.networkService.send(base64EncodedTx: builderResponse.tx.base64EncodedString()).map {[unowned self] response in
                var sendedTx = transaction
                sendedTx.hash = builderResponse.hash
                self.wallet.add(transaction: sendedTx)
                return true
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getFee(amount: Amount, source: String, destination: String) -> AnyPublisher<[Amount], Error> {
        guard let estimatedTxSize = self.getEstimateSize(for: Transaction(amount: amount, fee: Amount(with: amount, value: 0.0001), sourceAddress: source, destinationAddress: destination)) else {
            return Fail(error: CardanoError.failedToCalculateTxSize).eraseToAnyPublisher()
        }
        
        let a = Decimal(0.155381)
        let b = Decimal(0.000043946)
        
        let feeValue = a + b * estimatedTxSize
        let feeAmount = Amount(with: self.wallet.blockchain, address: self.wallet.address, value: feeValue)
        return Result.Publisher([feeAmount]).eraseToAnyPublisher()
    }
    
    private func getEstimateSize(for transaction: Transaction) -> Decimal? {
        guard let walletAmount = wallet.amounts[.coin]?.value,
            let tx = txBuilder.buildForSend(transaction: transaction, walletAmount: walletAmount, signature: Data(repeating: UInt8(0x01), count: 64)) else {
                return nil
        }
        
        return Decimal(tx.tx.count)
    }
}

extension CardanoWalletManager: ThenProcessable { }
