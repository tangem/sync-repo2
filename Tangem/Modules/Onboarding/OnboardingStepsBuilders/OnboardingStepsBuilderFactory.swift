//
//  OnboardingStepsBuilderFactory.swift
//  Tangem
//
//  Created by Alexander Osokin on 07.04.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk

protocol OnboardingStepsBuilderFactory {
    func makeOnboardingStepsBuilder(
        backupService: BackupService,
        pushNotificationsAvailabilityProvider: PushNotificationsAvailabilityProvider
    ) -> OnboardingStepsBuilder
}

// MARK: - Wallets

protocol WalletOnboardingStepsBuilderFactory: OnboardingStepsBuilderFactory, CardContainer {}

extension UserWalletConfig where Self: WalletOnboardingStepsBuilderFactory {
    func makeOnboardingStepsBuilder(
        backupService: BackupService,
        pushNotificationsAvailabilityProvider: PushNotificationsAvailabilityProvider
    ) -> OnboardingStepsBuilder {
        return WalletOnboardingStepsBuilder(
            cardId: card.cardId,
            hasWallets: isWalletsCreated,
            isBackupAllowed: card.settings.isBackupAllowed,
            isKeysImportAllowed: canImportKeys,
            canBackup: card.backupStatus?.canBackup ?? false,
            hasBackup: card.backupStatus?.isActive ?? false,
            canSkipBackup: canSkipBackup,
            backupService: backupService,
            pushNotificationsAvailabilityProvider: pushNotificationsAvailabilityProvider
        )
    }
}

// MARK: - Single cards

protocol SingleCardOnboardingStepsBuilderFactory: OnboardingStepsBuilderFactory, CardContainer {}

extension UserWalletConfig where Self: SingleCardOnboardingStepsBuilderFactory {
    func makeOnboardingStepsBuilder(
        backupService: BackupService,
        pushNotificationsAvailabilityProvider: PushNotificationsAvailabilityProvider
    ) -> OnboardingStepsBuilder {
        return SingleCardOnboardingStepsBuilder(
            cardId: card.cardId,
            hasWallets: !card.wallets.isEmpty,
            isMultiCurrency: hasFeature(.multiCurrency),
            pushNotificationsAvailabilityProvider: pushNotificationsAvailabilityProvider
        )
    }
}

// MARK: - Note cards

protocol NoteCardOnboardingStepsBuilderFactory: OnboardingStepsBuilderFactory, CardContainer {}

extension UserWalletConfig where Self: NoteCardOnboardingStepsBuilderFactory {
    func makeOnboardingStepsBuilder(
        backupService: BackupService,
        pushNotificationsAvailabilityProvider: PushNotificationsAvailabilityProvider
    ) -> OnboardingStepsBuilder {
        return NoteOnboardingStepsBuilder(
            cardId: card.cardId,
            hasWallets: !card.wallets.isEmpty,
            pushNotificationsAvailabilityProvider: pushNotificationsAvailabilityProvider
        )
    }
}

// MARK: - Visa cards

protocol VisaCardOnboardingStepsBuilderFactory: OnboardingStepsBuilderFactory, CardContainer {}

extension UserWalletConfig where Self: VisaCardOnboardingStepsBuilderFactory {
    func makeOnboardingStepsBuilder(
        backupService: BackupService,
        pushNotificationsAvailabilityProvider: PushNotificationsAvailabilityProvider
    ) -> OnboardingStepsBuilder {
        return VisaOnboardingStepsBuilder(
            pushNotificationsAvailabilityProvider: pushNotificationsAvailabilityProvider
        )
    }
}
