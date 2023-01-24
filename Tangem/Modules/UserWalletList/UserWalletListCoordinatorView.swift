//
//  UserWalletListCoordinatorView.swift
//  Tangem
//
//  Created by Andrey Chukavin on 30.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

struct UserWalletListCoordinatorView: CoordinatorView {
    @ObservedObject var coordinator: UserWalletListCoordinator

    init(coordinator: UserWalletListCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        ZStack {
            if let rootViewModel = coordinator.rootViewModel {
                UserWalletListView(viewModel: rootViewModel)
            }

            sheets
        }
    }

    @ViewBuilder
    private var sheets: some View {
        NavHolder()
            .sheet(item: $coordinator.mailViewModel) {
                MailView(viewModel: $0)
            }
    }
}
