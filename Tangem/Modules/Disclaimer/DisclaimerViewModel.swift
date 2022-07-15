//
//  DisclaimerViewModel.swift
//  Tangem
//
//  Created by Alexander Osokin on 15.06.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

class DisclaimerViewModel: Identifiable {
    let id: UUID = .init()

    let style: DisclaimerView.Style
    let showAccept: Bool

    private let userPrefsService: UserPrefsService = .init()
    private unowned let coordinator: DisclaimerRoutable?

    init(style: DisclaimerView.Style, showAccept: Bool, coordinator: DisclaimerRoutable?) {
        self.style = style
        self.showAccept = showAccept
        self.coordinator = coordinator
    }

    func onAccept() {
        userPrefsService.isTermsOfServiceAccepted = true
        dismissAccepted()
    }
}

// MARK: - Navigation
extension DisclaimerViewModel {
    private func dismissAccepted() {
        coordinator?.dismissAcceptedDisclaimer()
    }
}
