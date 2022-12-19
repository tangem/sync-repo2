//
//  BlockchainDataProvider.swift
//  Tangem
//
//  Created by Sergey Balashov on 15.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

public protocol BlockchainDataProvider {
    func getWalletAddress(currency: Currency) -> String?

    func getBalance(currency: Currency) async throws -> Decimal
    func getBalance(blockchain: ExchangeBlockchain) async throws -> Decimal
    func getFiat(amount: Decimal, currency: Currency) async throws -> Decimal
    func getFiat(amount: Decimal, blockchain: ExchangeBlockchain) async throws -> Decimal
}
