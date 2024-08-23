//
//  SendTransactionDispatcher.swift
//  Tangem
//
//  Created by Sergey Balashov on 28.06.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import TangemFoundation
import struct BlockchainSdk.SendTxError

protocol SendTransactionDispatcher {
    func send(transaction: SendTransactionType) async throws -> SendTransactionDispatcherResult
}

struct SendTransactionDispatcherResult: Hashable {
    let hash: String
    let url: URL?
}

extension SendTransactionDispatcherResult {
    enum Error: Swift.Error {
        case informationRelevanceServiceError
        case informationRelevanceServiceFeeWasIncreased

        case transactionNotFound
        case userCancelled
        case sendTxError(transaction: SendTransactionType, error: SendTxError)

        case demoAlert
        case stakingUnsupported
    }
}
