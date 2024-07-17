//
//  TransactionInfo.swift
//  TangemStaking
//
//  Created by Sergey Balashov on 12.07.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation

public struct TransactionInfo: Hashable {
    let id: String
    let actionId: String
    let network: String
    let type: TransactionType
    let status: TransactionStatus
    let unsignedTransactionData: Data
    let fee: Decimal
}
