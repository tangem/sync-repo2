//
//  LockedUserWallet.swift
//  Tangem
//
//  Created by Alexander Osokin on 31.05.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine

class LockedUserWallet: UserWalletModel {
    let walletModelsManager: WalletModelsManager = LockedWalletModelsManager()
    let userTokenListManager: UserTokenListManager = LockedUserTokenListManager()
    let userTokensManager: UserTokensManager = LockedUserTokensManager()
    var signer: TangemSigner

    var tokensCount: Int? { nil }

    var cardsCount: Int { config.cardsCount }

    var isMultiWallet: Bool { config.hasFeature(.multiCurrency) }

    var userWalletId: UserWalletId { .init(value: userWallet.userWalletId) }

    var emailConfig: EmailConfig? { nil }

    var didPerformInitialTokenSync: Bool { false }

    var updatePublisher: AnyPublisher<Void, Never> { .just }
    var didPerformInitialTokenSyncPublisher: AnyPublisher<Bool, Never> { .just(output: false) }

    private(set) var userWallet: UserWallet

    private let config: UserWalletConfig

    init(with userWallet: UserWallet) {
        self.userWallet = userWallet
        config = UserWalletConfigFactory(userWallet.cardInfo()).makeConfig()
        signer = TangemSigner(with: userWallet.card.cardId, sdk: config.makeTangemSdk())
    }

    func initialUpdate() {}

    func updateWalletName(_ name: String) {
        // Renaming locked wallets is prohibited
    }

    func totalBalancePublisher() -> AnyPublisher<LoadingValue<TotalBalanceProvider.TotalBalance>, Never> {
        .just(output: .loaded(.init(balance: 0, currencyCode: "", hasError: false)))
    }
}

extension LockedUserWallet: MainHeaderInfoProvider {
    var isUserWalletLocked: Bool { true }

    var userWalletNamePublisher: AnyPublisher<String, Never> {
        .just(output: userWallet.name)
    }

    var cardHeaderImage: ImageType? {
        config.cardHeaderImage
    }
}
