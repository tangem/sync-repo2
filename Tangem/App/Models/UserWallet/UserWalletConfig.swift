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

struct UserWalletConfig {
    let cardIdFormatted: String
    let emailConfig: EmailConfig
    let touURL: URL?
    let cardSetLabel: String?
    let cardIdDisplayFormat: CardIdDisplayFormat
    let features: Set<UserWalletConfig.Feature>
    
    let defaultBlockchain: Blockchain?
    let defaultToken: BlockchainSdk.Token?
    
    let onboardingSteps: OnboardingSteps
    let backupSteps: OnboardingSteps?
}

protocol UserWalletConfigBuilder {
    func buildConfig() -> UserWalletConfig
}

extension UserWalletConfigBuilder {
    func baseFeatures(for card: Card) -> Set<UserWalletConfig.Feature> {
        var features = Set<UserWalletConfig.Feature>()
        
        if card.firmwareVersion.doubleValue >= 4.52 {
            features.insert(.longHashesSupported)
        }
        
        
        if card.firmwareVersion.doubleValue >= 2.28
            || card.settings.securityDelay <= 15000 {
            features.insert(.signingSupported)
        }
        
        return features
    }
}

class UserWalletConfigBuilderFactory {
    static func makeBuilder(for cardInfo: CardInfo) -> UserWalletConfigBuilder {
        switch cardInfo.walletData {
        case .none:
            return GenericConfigBuilder(card: cardInfo.card)
        case .note(let noteData):
            return NoteConfigBuilder(card: cardInfo.card, noteData: noteData)
        case .twin(let twinData):
            return TwinConfigBuilder(card: cardInfo.card, twinData: twinData)
        case .v3(let walletData):
            if cardInfo.card.issuer.name.lowercased() == "start2coin" {
                return Start2CoinConfigBuilder(card: cardInfo.card, walletData: walletData)
            }
            
            return V3ConfigBuilder(card: cardInfo.card, walletData: walletData)
        }
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
