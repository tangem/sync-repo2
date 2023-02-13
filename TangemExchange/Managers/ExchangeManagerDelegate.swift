//
//  ExchangeManagerDelegate.swift
//  TangemExchange
//
//  Created by Sergey Balashov on 24.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

public protocol ExchangeManagerDelegate: AnyObject {
    func exchangeManager(_ manager: ExchangeManager, didUpdate exchangeItems: ExchangeItems)
    func exchangeManager(_ manager: ExchangeManager, didUpdate availabilityState: ExchangeAvailabilityState)
}
