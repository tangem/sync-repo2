//
//  ExchangeTransactionInfo.swift
//  TangemExchange
//
//  Created by Sergey Balashov on 23.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

public struct ExchangeTransactionInfo {
    public let currency: Currency
    public let destination: String
    public let amount: Decimal
    public let oneInchTxData: Data
}
