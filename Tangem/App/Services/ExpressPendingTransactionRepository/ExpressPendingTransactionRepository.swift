//
//  ExpressPendingTransactionRepository.swift
//  TangemSwapping
//
//  Created by Sergey Balashov on 10.11.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import TangemSwapping

protocol ExpressPendingTransactionRepository: AnyObject {
    var allExpressTransactions: [ExpressPendingTransactionRecord] { get }
    var pendingCEXTransactionsPublisher: AnyPublisher<[ExpressPendingTransactionRecord], Never> { get }

    func swapTransactionDidSend(_ txData: SentExpressTransactionData, userWalletId: String)
    func swapTransactionDidComplete(with expressTxId: String)
}

private struct ExpressPendingTransactionRepositoryKey: InjectionKey {
    static var currentValue: ExpressPendingTransactionRepository = CommonExpressPendingTransactionRepository()
}

extension InjectedValues {
    var expressPendingTransactionsRepository: ExpressPendingTransactionRepository {
        get { Self[ExpressPendingTransactionRepositoryKey.self] }
        set { Self[ExpressPendingTransactionRepositoryKey.self] = newValue }
    }
}
