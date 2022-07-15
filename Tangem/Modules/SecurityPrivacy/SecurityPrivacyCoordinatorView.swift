//
//  SecurityPrivacyCoordinatorView.swift
//  Tangem
//
//  Created by Sergey Balashov on 29.06.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

struct SecurityPrivacyCoordinatorView: CoordinatorView {
    @ObservedObject var coordinator: SecurityPrivacyCoordinator

    var body: some View {
        if let model = coordinator.securityPrivacyViewModel {
            SecurityPrivacyView(viewModel: model)
                .navigation(item: $coordinator.securityManagementCoordinator) {
                    SecurityManagementCoordinatorView(coordinator: $0)
                }
                .emptyNavigationLink()
        }
    }
}
