//
//  Amount.swift
//  BlockchainSdk
//
//  Created by Alexander Osokin on 13.04.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation

public struct Amount {
    public enum AmountType {
        case coin
        case token
        case reserve
    }
    
    let type: AmountType
    let currencySymbol: String
    var value: Decimal
    let decimals: Int
    
    public init(with blockchain: Blockchain, address: String, type: AmountType = .coin, value: Decimal) { //TODO: remove address?
        self.type = type
        currencySymbol = blockchain.currencySymbol
        decimals = blockchain.decimalCount
        self.value = value
    }
    
    public init(with token: Token, value: Decimal) {
        type = .token
        currencySymbol = token.currencySymbol
        decimals = token.decimalCount
        self.value = value
    }
    
    public init(with amount: Amount, value: Decimal) {
        type = amount.type
        currencySymbol = amount.currencySymbol
        decimals = amount.decimals
        self.value = value
    }
}


