//
//  DefaultExchangeLogger.swift
//  TangemExchange
//
//  Created by Alexander Osokin on 30.12.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

struct DefaultExchangeLogger: ExchangeLogger {
    func error(_ error: Error) {
        print(error)
    }

    func debug<T>(_ message: @autoclosure () -> T) {
        print(message())
    }
}
