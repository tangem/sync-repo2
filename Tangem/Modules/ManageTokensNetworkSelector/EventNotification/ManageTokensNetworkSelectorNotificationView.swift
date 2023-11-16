//
//  ManageTokensNetworkSelectorNotificationView.swift
//  Tangem
//
//  Created by skibinalexander on 16.11.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI
import Combine

struct ManageTokensNetworkSelectorNotificationView: View {
    @ObservedObject var viewModel: ManageTokensNetworkSelectorNotificationViewModel

    var body: some View {
        if let notificationInput = viewModel.notificationInput {
            NotificationView(input: notificationInput)
                .transition(.notificationTransition)
        }
    }
}
