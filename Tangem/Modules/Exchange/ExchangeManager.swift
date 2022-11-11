//
//  ExchangeManager.swift
//  Tangem
//
//  Created by Pavel Grechikhin on 07.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk

protocol ExchangeManager {
    var walletAddress: String { get }

    func send(_ tx: Transaction, signer: TangemSigner) async throws
    func getFee(amount: Amount, destination: String) async throws -> [Amount]
    func createTransaction(amount: Amount, fee: Amount, destinationAddress: String,
                           sourceAddress: String?, changeAddress: String?) throws -> Transaction
}

extension ExchangeManager {
    func createTransaction(amount: Amount,
                           fee: Amount,
                           destinationAddress: String,
                           sourceAddress: String? = nil,
                           changeAddress: String? = nil) throws -> Transaction {
        try self.createTransaction(amount: amount,
                                   fee: fee,
                                   destinationAddress: destinationAddress,
                                   sourceAddress: sourceAddress,
                                   changeAddress: changeAddress)
    }
}
