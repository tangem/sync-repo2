//
//  TokenActionContextBuilder.swift
//  Tangem
//
//  Created by skibinalexander on 20.08.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation

protocol TokenActionContextProvider: AnyObject {
    func buildContextActions(for walletModelId: WalletModelId, with userWalletId: UserWalletId) -> [TokenActionType]
}

final class TokenActionContextBuilder {
    // MARK: - Private Properties

    @Injected(\.swapAvailabilityProvider) private var swapAvailabilityProvider: SwapAvailabilityProvider

    private let userWalletModels: [UserWalletModel]

    // MARK: - Init

    init(userWalletModels: [UserWalletModel]) {
        self.userWalletModels = userWalletModels
    }
}

// MARK: - TokenItemContextActionsProvider

extension TokenActionContextBuilder: MarketsPortfolioContextActionsProvider {
    func buildContextActions(for walletModelId: WalletModelId, with userWalletId: UserWalletId) -> [TokenActionType] {
        guard
            let userWalletModel = userWalletModels.first(where: { $0.userWalletId == userWalletId }),
            let walletModel = userWalletModel.walletModelsManager.walletModels.first(where: { $0.id == walletModelId }),
            TokenInteractionAvailabilityProvider(walletModel: walletModel).isContextMenuAvailable()
        else {
            return []
        }

        let actionsBuilder = TokenActionListBuilder()

        let utility = ExchangeCryptoUtility(
            blockchain: walletModel.blockchainNetwork.blockchain,
            address: walletModel.defaultAddress,
            amountType: walletModel.amountType
        )

        let canExchange = userWalletModel.config.isFeatureVisible(.exchange)
        // On the Main view we have to hide send button if we have any sending restrictions
        let canSend = userWalletModel.config.hasFeature(.send) && walletModel.sendingRestrictions == .none
        let canSwap = userWalletModel.config.isFeatureVisible(.swapping) &&
            swapAvailabilityProvider.canSwap(tokenItem: walletModel.tokenItem) &&
            !walletModel.isCustom

        let canStake = StakingFeatureProvider().canStake(with: userWalletModel, by: walletModel)

        let isBlockchainReachable = !walletModel.state.isBlockchainUnreachable
        let canSignTransactions = walletModel.sendingRestrictions != .cantSignLongTransactions

        let contextActions = actionsBuilder.buildTokenContextActions(
            canExchange: canExchange,
            canSignTransactions: canSignTransactions,
            canSend: canSend,
            canSwap: canSwap,
            canStake: canStake,
            canHide: false,
            isBlockchainReachable: isBlockchainReachable,
            exchangeUtility: utility
        )

        return contextActions
    }
}
