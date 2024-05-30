//
//  PushNotificationsStepView.swift
//  Tangem
//
//  Created by Alexander Osokin on 30.05.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import SwiftUI

struct PushNotificationsStepView: View {
    @ObservedObject var viewModel: PushNotificationsStepViewModel

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    PushNotificationsStepView(viewModel: .init(routable: WelcomeOnboardingStepRoutableStub()))
}
