//
//  FakeTokenQuotesRepository.swift
//  Tangem
//
//  Created by Andrew Son on 25/09/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine

class FakeTokenQuotesRepository: TokenQuotesRepository {
    var pricesPublisher: AnyPublisher<Quotes, Never> {
        currentPrices.eraseToAnyPublisher()
    }

    private let currentPrices = CurrentValueSubject<Quotes, Never>([:])

    func quote(for item: TokenItem) -> TokenQuote? {
        guard let id = item.currencyId else {
            return nil
        }

        return currentPrices.value[id]
    }

    func quote(for coinId: String) -> TokenQuote? {
        return currentPrices.value[coinId]
    }

    func loadQuotes(coinIds: [String]) -> AnyPublisher<[TokenQuote], Never> {
        let filter = Set(coinIds)
        return currentPrices
            .map { newQuotes in
                newQuotes.filter {
                    filter.contains($0.key)
                }
                .map { $0.value }
            }
            .eraseToAnyPublisher()
    }
}
