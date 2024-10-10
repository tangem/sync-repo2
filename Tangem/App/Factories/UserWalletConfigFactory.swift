//
//  UserWalletConfigFactory.swift
//  Tangem
//
//  Created by Alexander Osokin on 11.08.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
import BlockchainSdkLocal

struct UserWalletConfigFactory {
    private let cardInfo: CardInfo

    #warning("TODO: Add ability to create config based on UserWallet")

    init(_ cardInfo: CardInfo) {
        self.cardInfo = cardInfo
    }

    func makeConfig() -> UserWalletConfig {
        let isDemo = DemoUtil().isDemoCard(cardId: cardInfo.card.cardId)
        let isS2CCard = cardInfo.card.issuer.name.lowercased() == "start2coin"
        let isRing = cardInfo.card.batchId == "AC17" || cardInfo.card.batchId == "BA01"
        let isVisa = cardInfo.card.batchId == "AE04"

        switch cardInfo.walletData {
        case .none:
            // old multiwallet
            if cardInfo.card.firmwareVersion <= .backupAvailable {
                return LegacyConfig(card: cardInfo.card, walletData: nil)
            }

            if FirmwareVersion.visaRange.contains(cardInfo.card.firmwareVersion.doubleValue), isVisa {
                return VisaConfig(card: cardInfo.card)
            }

            let isWallet2 = cardInfo.card.firmwareVersion >= .ed25519Slip0010Available

            switch (isWallet2, isDemo) {
            case (true, _):
                return Wallet2Config(card: cardInfo.card, isDemo: isDemo, isRing: isRing)
            case (false, true): // TODO: Combine configs
                return GenericDemoConfig(card: cardInfo.card)
            case (false, false):
                return GenericConfig(card: cardInfo.card, isRing: isRing)
            }
        case .file(let noteData):
            if isS2CCard { // TODO: refactor factory
                return Start2CoinConfig(card: cardInfo.card, walletData: noteData)
            }

            if isDemo {
                return NoteDemoConfig(card: cardInfo.card, noteData: noteData)
            } else {
                return NoteConfig(card: cardInfo.card, noteData: noteData)
            }
        case .twin(let walletData, let twinData):
            return TwinConfig(card: cardInfo.card, walletData: walletData, twinData: twinData)
        case .legacy(let walletData):
            if isS2CCard {
                return Start2CoinConfig(card: cardInfo.card, walletData: walletData)
            }

            return LegacyConfig(card: cardInfo.card, walletData: walletData)
        }
    }
}
