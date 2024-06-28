//
//  PushNotificationsHelperFactory.swift
//  Tangem
//
//  Created by m3g0byt3 on 27.06.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation

struct PushNotificationsHelperFactory {
    // FIXME: Andrey Fedorov - Test only, remove when not needed
    private var pushNotificationsInteractor: CommonPushNotificationsInteractor { CommonPushNotificationsInteractor.shared }

    func makeAvailabilityProviderForWelcomeOnboarding() -> PushNotificationsAvailabilityProvider {
        return makeTrampolineForFlow(.newUser(state: .welcomeOnboarding))
    }

    func makeAvailabilityProviderForWalletOnboarding() -> PushNotificationsAvailabilityProvider {
        return makeTrampolineForFlow(.newUser(state: .walletOnboarding))
    }

    func makePermissionManagerForWelcomeOnboarding() -> PushNotificationsPermissionManager {
        return makeTrampolineForFlow(.newUser(state: .welcomeOnboarding))
    }

    func makePermissionManagerForWalletOnboarding() -> PushNotificationsPermissionManager {
        return makeTrampolineForFlow(.newUser(state: .walletOnboarding))
    }

    private func makeTrampolineForFlow(
        _ flow: CommonPushNotificationsInteractor.PermissionRequestFlow
    ) -> PushNotificationsInteractorTrampoline {
        return PushNotificationsInteractorTrampoline(
            isAvailable: { await pushNotificationsInteractor.isAvailable(in: flow) },
            canPostponePermissionRequest: { pushNotificationsInteractor.canPostponeRequest(in: flow) },
            allowRequest: { await pushNotificationsInteractor.allowRequest(in: flow) },
            postponeRequest: { pushNotificationsInteractor.postponeRequest(in: flow) }
        )
    }
}
