//
//  TokenItemInfoProvider.swift
//  Tangem
//
//  Created by Andrew Son on 28/04/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Combine
import BlockchainSdk

protocol TokenItemInfoProvider: AnyObject {
    var walletDidChangePublisher: AnyPublisher<WalletModel.State, Never> { get }
    var hasPendingTransactions: Bool { get }
    var balance: String { get }
    var fiatBalance: String { get }
}
