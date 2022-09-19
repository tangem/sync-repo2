//
//  UserWalletStorageAgreementViewModel.swift
//  Tangem
//
//  Created by Andrey Chukavin on 16.08.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Combine
import SwiftUI

final class UserWalletStorageAgreementViewModel: ObservableObject, Identifiable {
    // MARK: - ViewState

    let showButtons: Bool

    // MARK: - Dependencies

    private unowned let coordinator: UserWalletStorageAgreementRoutable

    init(
        showButtons: Bool,
        coordinator: UserWalletStorageAgreementRoutable
    ) {
        self.showButtons = showButtons
        self.coordinator = coordinator
    }

    func accept() {
        coordinator.didAgree()
    }

    func decline() {
        coordinator.didDecline()
    }
}
