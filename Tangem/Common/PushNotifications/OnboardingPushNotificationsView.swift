//
//  OnboardingPushNotificationsView.swift
//  Tangem
//
//  Created by Alexander Osokin on 06.06.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import SwiftUI

struct OnboardingPushNotificationsView: View {
    @ObservedObject var viewModel: OnboardingPushNotificationsViewModel

    var body: some View {
        VStack {
            Spacer()

            // TODO: https://tangem.atlassian.net/browse/IOS-6136
            Text("PUSH NOTIFICATIONS CONTENT")

            Spacer()

            buttons
        }
    }

    private var buttons: some View {
        VStack {
            MainButton(
                title: viewModel.allowButtonTitle,
                action: viewModel.didTapAllow
            )

            MainButton(
                title: viewModel.laterButtonTitle,
                style: .secondary,
                action: viewModel.didTapLater
            )
        }
        .padding(.top, 14)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Previews

#Preview {
    let permissionManager = PushNotificationsInteractorTrampoline(
        isAvailable: { true },
        canPostponePermissionRequest: { true },
        allowRequest: {},
        postponeRequest: {}
    )
    let viewModel = OnboardingPushNotificationsViewModel(
        permissionManager: permissionManager,
        delegate: OnboardingPushNotificationsDelegateStub()
    )
    return OnboardingPushNotificationsView(viewModel: viewModel)
}
