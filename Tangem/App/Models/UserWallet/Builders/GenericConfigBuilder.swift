//
//  GenericConfigBuilder.swift
//  Tangem
//
//  Created by Alexander Osokin on 01.08.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk

class GenericConfigBuilder: UserWalletConfigBuilder {
    @Injected(\.backupServiceProvider) private var backupServiceProvider: BackupServiceProviding
    
    private let card: Card

    private var onboardingSteps: [WalletOnboardingStep] {
        if card.wallets.isEmpty {
            return [.createWallet] + backupSteps
        } else {
            if !AppSettings.shared.cardsStartedActivation.contains(card.cardId) {
                return []
            }
            
            return backupSteps
        }
    }
    
    private var backupSteps: [WalletOnboardingStep] {
        if !card.settings.isBackupAllowed {
            return []
        }
        
        var steps: [WalletOnboardingStep] = .init()
        
        steps.append(.backupIntro)

        if !backupServiceProvider.backupService.primaryCardIsSet {
            steps.append(.scanPrimaryCard)
        }

        if backupServiceProvider.backupService.addedBackupCardsCount < BackupService.maxBackupCardsCount {
            steps.append(.selectBackupCards)
        }

        steps.append(.backupCards)
        steps.append(.success)

        return steps
    }
    
    init(card: Card) {
        self.card = card
    }

    func buildConfig() -> UserWalletConfig {
        var features = baseFeatures(for: card)
        
        features.insert(.sendingToPayIDAllowed)
        features.insert(.exchangingAllowed)
        features.insert(.walletConnectAllowed)
        features.insert(.manageTokensAllowed)
        features.insert(.activation)
        
        let cardSetLabel: String? = card.backupStatus?.backupCardsCount.map {
            .init(format: "card_label_number_format".localized, 1, $0 + 1)
        }
      
        let config = UserWalletConfig(cardIdFormatted: AppCardIdFormatter(cid: card.cardId).formatted(),
                                      emailConfig: .default,
                                      touURL: nil,
                                      cardSetLabel: cardSetLabel,
                                      cardIdDisplayFormat: .full,
                                      features: features,
                                      defaultBlockchain: nil,
                                      defaultToken: nil,
                                      onboardingSteps: .wallet(onboardingSteps),
                                      backupSteps: .wallet(backupSteps))
        
        return config
    }
}

fileprivate extension Card.BackupStatus {
    var backupCardsCount: Int? {
        if case let .active(backupCards) = self {
            return backupCards
        }
        
        return nil
    }
}
