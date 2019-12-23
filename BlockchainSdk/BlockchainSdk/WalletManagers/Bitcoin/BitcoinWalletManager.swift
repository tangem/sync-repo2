//
//  Bitcoin.swift
//  BlockchainSdk
//
//  Created by Alexander Osokin on 06.12.2019.
//  Copyright © 2019 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
import Combine

enum BitcoinError: Error {
    case noUnspents
    case failedToBuildHash
    case failedToBuildTransaction
    case failedToMapNetworkResponse
    case failedToCalculateTxSize
}

class BitcoinWalletManager: WalletManager {
    var wallet: CurrentValueSubject<Wallet, Error>
    
    private let currencyWallet: CurrencyWallet
    private let txBuilder: BitcoinTransactionBuilder
    private let network: BitcoinNetworkManager
    private let cardId: String
    private var updateSubscription: AnyCancellable?
    
    init(cardId: String, walletPublicKey: Data, walletConfig: WalletConfig, isTestnet: Bool) {
        self.cardId = cardId
        let blockchain: Blockchain = isTestnet ? .bitcoinTestnet : .bitcoin
        let address = blockchain.makeAddress(from: walletPublicKey)
        currencyWallet = CurrencyWallet(address: address, blockchain: blockchain, config: walletConfig)
        self.txBuilder = BitcoinTransactionBuilder(walletAddress: address, walletPublicKey: walletPublicKey, isTestnet: isTestnet)
        wallet = CurrentValueSubject(currencyWallet)
        network = BitcoinNetworkManager(address: address, isTestNet: isTestnet)
    }
    
    func update() {
        updateSubscription = network.getInfo()
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    self.wallet.send(completion: .failure(error))
                }
            }, receiveValue: { [unowned self] in
                self.updateWallet(with: $0)
            })
    }
    
    private func updateWallet(with response: BitcoinResponse) {
        currencyWallet.balances[.coin]?.value = response.balance
        txBuilder.unspentOutputs = response.txrefs
        if response.hacUnconfirmed {
            if currencyWallet.pendingTransactions.isEmpty {
                currencyWallet.pendingTransactions.append(Transaction(amount: Amount(with: currencyWallet.blockchain, address: ""), fee: nil, sourceAddress: "unknown", destinationAddress: currencyWallet.address))
            }
        } else {
            currencyWallet.pendingTransactions = []
        }
        wallet.send(currencyWallet)
    }
}

extension BitcoinWalletManager: TransactionBuilder {
    func getEstimateSize(for transaction: Transaction) -> Decimal? {
        guard let unspentOutputsCount = txBuilder.unspentOutputs?.count else {
            return nil
        }
        
        guard let tx = txBuilder.buildForSend(transaction: transaction, signature: Data(repeating: UInt8(0x01), count: 64 * unspentOutputsCount)) else {
            return nil
        }
        
        return Decimal(tx.count + 1)
    }
}

extension BitcoinWalletManager: TransactionSender {
    func send(_ transaction: Transaction, signer: TransactionSigner) -> AnyPublisher<Bool, Error> {
        guard let hashes = txBuilder.buildForSign(transaction: transaction) else {
            return Fail(error: BitcoinError.failedToBuildHash).eraseToAnyPublisher()
        }
        
        return signer.sign(hashes: hashes, cardId: cardId)
            .tryMap {[unowned self] response in
                guard let tx = self.txBuilder.buildForSend(transaction: transaction, signature: response.signature) else {
                    throw BitcoinError.failedToBuildTransaction
                }
                return tx.toHexString()
        }
        .flatMap {[unowned self] in
            self.network.send(transaction: $0).map {[unowned self] response in
                self.currencyWallet.add(transaction: transaction)
                self.wallet.send(self.currencyWallet)
                return true
            }
        }
        .eraseToAnyPublisher()
    }
}

extension BitcoinWalletManager: FeeProvider {
    func getFee(amount: Amount, source: String, destination: String) -> AnyPublisher<[Amount], Error> {
        return network.getFee()
            .tryMap {[unowned self] response throws -> [Amount] in
                let kb = Decimal(1024)
                let minPerByte = response.minimalKb/kb
                let normalPerByte = response.normalKb/kb
                let maxPerByte = response.priorityKb/kb
                
                guard let estimatedTxSize = self.getEstimateSize(for: Transaction(amount: amount, fee: nil, sourceAddress: source, destinationAddress: destination)) else {
                    throw BitcoinError.failedToCalculateTxSize
                }
                
                let minFee = (minPerByte * estimatedTxSize)
                let normalFee = (normalPerByte * estimatedTxSize)
                let maxFee = (maxPerByte * estimatedTxSize)
                return [
                    Amount(with: self.currencyWallet.blockchain, address: source, value: minFee),
                    Amount(with: self.currencyWallet.blockchain, address: source, value: normalFee),
                    Amount(with: self.currencyWallet.blockchain, address: source, value: maxFee)
                ]
        }
        .eraseToAnyPublisher()
    }
}
