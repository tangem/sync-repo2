//
//  SecurityPrivacyViewModel.swift
//  Tangem
//
//  Created by Sergey Balashov on 29.06.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import Combine

class SecurityPrivacyViewModel: ObservableObject {
    private unowned let coordinator: SecurityPrivacyRoutable

    private let cardModel: CardViewModel

    init(
        cardModel: CardViewModel,
        coordinator: SecurityPrivacyRoutable
    ) {
        self.cardModel = cardModel
        self.coordinator = coordinator
    }
}

// MARK: View Output

extension SecurityPrivacyViewModel {
    func openChangePassword() {
        coordinator.openChangePassword()
    }

    func openSecurityManagement() {
        coordinator.openSecurityManagement(cardModel: cardModel)
    }

    func openTokenSynchronization() {
        coordinator.openTokenSynchronization()
    }

    func openResetSavedCards() {
        coordinator.openResetSavedCards()
    }
}
