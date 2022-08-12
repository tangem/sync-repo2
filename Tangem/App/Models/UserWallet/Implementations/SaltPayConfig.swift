//
//  SaltPayConfig.swift
//  Tangem
//
//  Created by Alexander Osokin on 08.08.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

import Foundation
import TangemSdk
import BlockchainSdk

struct SaltPayConfig: BaseConfig, WalletModelBuilder {
    private let card: Card
    private let walletData: WalletData

    init(card: Card, walletData: WalletData) {
        self.card = card
        self.walletData = walletData
    }

    private var defaultBlockchain: Blockchain {
        return Blockchain.from(blockchainName: walletData.blockchain, curve: card.supportedCurves[0])!
    }
}

extension SaltPayConfig: UserWalletConfig {
    var emailConfig: EmailConfig {
        .default
    }

    var touURL: URL? {
        nil
    }

    var cardSetLabel: String? {
        nil
    }

    var cardIdDisplayFormat: CardIdDisplayFormat {
        .full
    }

    var defaultCurve: EllipticCurve? {
        defaultBlockchain.curve
    }

    var onboardingSteps: OnboardingSteps {
        if card.wallets.isEmpty {
            return .singleWallet([.createWallet, .success])
        }

        return .singleWallet([])
    }

    var backupSteps: OnboardingSteps? {
        return nil
    }

    var supportedBlockchains: Set<Blockchain> {
        [defaultBlockchain]
    }

    var defaultBlockchains: [StorageEntry] {
        let derivationPath = defaultBlockchain.derivationPath(for: .legacy)
        let network = BlockchainNetwork(defaultBlockchain, derivationPath: derivationPath)
        let entry = StorageEntry(blockchainNetwork: network, tokens: [])
        return [entry]
    }

    var persistentBlockchains: [StorageEntry]? {
        nil
    }

    var embeddedBlockchain: StorageEntry? {
        defaultBlockchains.first
    }

    var warningEvents: [WarningEvent] { getBaseWarningEvents(for: card) }

    var tangemSigner: TangemSigner { .init(with: card.cardId) }

    func getFeatureAvailability(_ feature: UserWalletFeature) -> UserWalletFeature.Availability {
        .unavailable
    }

    func makeWalletModels(for tokens: [StorageEntry], derivedKeys: [DerivationPath: ExtendedPublicKey]) -> [WalletModel] {
        if let model = makeSingleWallet() {
            return [model]
        }

        return []
    }
}
