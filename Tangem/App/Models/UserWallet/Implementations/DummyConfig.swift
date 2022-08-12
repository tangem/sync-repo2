//
//  DummyConfig.swift
//  Tangem
//
//  Created by Alexander Osokin on 05.08.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
import BlockchainSdk

struct DummyConfig: UserWalletConfig {
    var emailConfig: EmailConfig { .default }

    var touURL: URL? { nil }

    var cardSetLabel: String? { nil }

    var cardIdDisplayFormat: CardIdDisplayFormat { .full }

    var features: Set<UserWalletFeature> { [] }

    var defaultCurve: EllipticCurve? { nil }

    var onboardingSteps: OnboardingSteps { .wallet([]) }

    var backupSteps: OnboardingSteps? { nil }

    var supportedBlockchains: Set<Blockchain> { Blockchain.supportedBlockchains }

    var defaultBlockchains: [StorageEntry] { [] }

    var persistentBlockchains: [StorageEntry]? { nil }

    var embeddedBlockchain: StorageEntry? { nil }

    var warningEvents: [WarningEvent] { [] }

    var tangemSigner: TangemSigner { .init(with: nil) }

    func getFeatureAvailability(_ feature: UserWalletFeature) -> UserWalletFeature.Availability {
        return .available
    }

    func makeWalletModels(for tokens: [StorageEntry], derivedKeys: [DerivationPath: ExtendedPublicKey]) -> [WalletModel] {
        []
    }
}
