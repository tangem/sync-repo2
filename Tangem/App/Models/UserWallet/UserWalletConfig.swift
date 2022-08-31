//
//  UserWalletConfig.swift
//  Tangem
//
//  Created by Alexander Osokin on 29.07.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
import BlockchainSdk

protocol UserWalletConfig {
    var sdkConfig: Config { get }

    var emailConfig: EmailConfig { get }

    var touURL: URL? { get }

    var cardsCount: Int { get }

    var cardSetLabel: String? { get }

    var cardName: String { get }

    var defaultCurve: EllipticCurve? { get }

    var tangemSigner: TangemSigner { get }

    var warningEvents: [WarningEvent] { get }

    var onboardingSteps: OnboardingSteps { get }

    var backupSteps: OnboardingSteps? { get }

    /// All blockchains supported by this user wallet.
    var supportedBlockchains: Set<Blockchain> { get }

    /// Blockchains to be added to the tokens list by default on wallet creation.
    var defaultBlockchains: [StorageEntry] { get }

    /// Blockchains to be added to the tokens list on every scan. E.g. demo blockchains.
    var persistentBlockchains: [StorageEntry]? { get }

    /// Blockchain which embedded in the card.
    var embeddedBlockchain: StorageEntry? { get }

    var emailData: [EmailCollectedData] { get }

    func getFeatureAvailability(_ feature: UserWalletFeature) -> UserWalletFeature.Availability

    func makeWalletModels(for tokens: [StorageEntry]) -> [WalletModel]
}

extension UserWalletConfig {
    var sdkConfig: Config {
        TangemSdkConfigFactory().makeDefaultConfig()
    }

    var needUserWalletSavingSteps: Bool {
        return BiometricsUtil.isAvailable && !AppSettings.shared.saveUserWallets
    }

    func hasFeature(_ feature: UserWalletFeature) -> Bool {
        getFeatureAvailability(feature).isAvailable
    }
}

struct EmailConfig {
    let recipient: String
    let subject: String

    static var `default`: EmailConfig {
        .init(recipient: "support@tangem.com",
              subject: "feedback_subject_support_tangem".localized)
    }
}

