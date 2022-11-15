//
//  TangemExchangeFactory.swift
//  TangemExchange
//
//  Created by Sergey Balashov on 15.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

/// Public factory for work with exchange
enum TangemExchangeFactory {
    static func createExchangeManager(source: Currency, destination: Currency?) -> ExchangeManager {
        let exchangeItems = CommonExchangeManager.ExchangeItems(source: source, destination: destination)
        let provider = ExchangeOneInchProvider(exchangeManager: <#T##ExchangeManager#>, signer: <#T##<<error type>>#>, blockchainNetwork: <#T##<<error type>>#>)
        return CommonExchangeManager(provider: ExchangeProvider, exchangeItems: exchangeItems)
    }
}
