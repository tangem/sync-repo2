//
//  MarketsPortfolioContextActions.swift
//  Tangem
//
//  Created by skibinalexander on 14.07.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation

protocol MarketsPortfolioContextActionsProvider: AnyObject {
    func buildContextActions(walletModelId: WalletModelId, userWalletId: UserWalletId) -> [TokenActionType]
}

protocol MarketsPortfolioContextActionsDelegate: AnyObject {
    func didTapContextAction(_ action: TokenActionType, walletModelId: WalletModelId, userWalletId: UserWalletId)
}
