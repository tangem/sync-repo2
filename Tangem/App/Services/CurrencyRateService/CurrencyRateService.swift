//
//  CurrencyRateService.swift
//  Tangem
//
//  Created by Alexander Osokin on 06.05.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import Combine

protocol CurrencyRateService {
    func rates(for coinIds: [String]) -> AnyPublisher<[String: Decimal], Never>
    func baseCurrencies() -> AnyPublisher<[CurrenciesResponse.Currency], Error>
}

private struct CurrencyRateServiceKey: InjectionKey {
    static var currentValue: CurrencyRateService = CommonCurrencyRateService()
}

extension InjectedValues {
    var currencyRateService: CurrencyRateService {
        get { Self[CurrencyRateServiceKey.self] }
        set { Self[CurrencyRateServiceKey.self] = newValue }
    }
}
