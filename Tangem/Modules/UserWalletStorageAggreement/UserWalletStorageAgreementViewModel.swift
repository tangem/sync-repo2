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

    let isStandalone: Bool

    // MARK: - Dependencies

    private unowned let coordinator: UserWalletStorageAgreementRoutable?

    init(
        isStandalone: Bool,
        coordinator: UserWalletStorageAgreementRoutable?
    ) {
        self.isStandalone = isStandalone
        self.coordinator = coordinator
    }

    func accept() {
        coordinator?.didAgree()
    }

    func decline() {
        coordinator?.didDecline()
    }
}
