//
//  BinanceWalletManager.swift
//  BlockchainSdk
//
//  Created by Alexander Osokin on 15.02.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import RxSwift

class BinanceWalletManager: WalletManager {
    var txBuilder: BinanceTransactionBuilder!
    var network: BinanceNetworkManager!
    private var latestTxDate: Date?
    
    override func update(completion: @escaping (Result<Wallet, Error>)-> Void) {//check it
        requestDisposable = network
            .getInfo()
            .subscribe(onSuccess: {[unowned self] response in
                self.updateWallet(with: response)
                completion(.success(self.wallet))
                }, onError: {error in
                    completion(.failure(error))
            })
    }
    
    private func updateWallet(with response: BinanceInfoResponse) {
        wallet.add(coinValue: Decimal(response.balance))
        txBuilder.binanceWallet.sequence = response.sequence
        txBuilder.binanceWallet.accountNumber = response.accountNumber
        
        let currentDate = Date()
        for  index in wallet.transactions.indices {
            if DateInterval(start: wallet.transactions[index].date!, end: currentDate).duration > 10 {
                wallet.transactions[index].status = .confirmed
            }
        }
    }
}

@available(iOS 13.0, *)
extension BinanceWalletManager: TransactionSender {
    func send(_ transaction: Transaction, signer: TransactionSigner) -> AnyPublisher<Bool, Error> {
        let msg = txBuilder.buildForSign(amount: transaction.amount.value, targetAddress: transaction.destinationAddress)
        let hash = msg.encodeForSignature()
        return signer.sign(hashes: [hash], cardId: cardId)
            .tryMap {[unowned self] response in
                guard let tx = self.txBuilder.buildForSend(signature: response.signature, hash: hash) else {
                    throw BitcoinError.failedToBuildTransaction
                }
                return tx
        }
        .flatMap {[unowned self] in
            self.network.send(transaction: $0).map {[unowned self] response in
                self.wallet.add(transaction: transaction)
                self.latestTxDate = Date()
                return true
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getFee(amount: Amount, source: String, destination: String) -> AnyPublisher<[Amount], Error> {
        return network.getFee()
            .tryMap { feeString throws -> [Amount] in
                guard let feeValue = Decimal(feeString) else {
                    throw "Failed to get fee"
                }
                
                return [Amount(with: self.wallet.blockchain, address: source, value: feeValue)]
        }
        .eraseToAnyPublisher()
    }
}

extension BinanceWalletManager: ThenProcessable { }
