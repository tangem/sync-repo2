//
//  CommonExpressPendingTransactionRepository.swift
//  Tangem
//
//  Created by Sergey Balashov on 13.11.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import TangemSwapping

class CommonExpressPendingTransactionRepository {}

extension CommonExpressPendingTransactionRepository: ExpressPendingTransactionRepository {
    func hasPending(for network: String) -> Bool {
        false
    }

    func didSendSwapTransaction(swappingTxData: SwappingTransactionData) {}

    func didSendApproveTransaction(swappingTxData: SwappingTransactionData) {}
}
