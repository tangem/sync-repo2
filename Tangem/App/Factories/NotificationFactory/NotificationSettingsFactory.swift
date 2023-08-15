//
//  NotificationSettingsFactory.swift
//  Tangem
//
//  Created by Andrew Son on 14/08/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

struct NotificationSettingsFactory {
    func buildMissingDerivationNotifSettings(for numberOfNetworks: Int) -> NotificationView.Settings {
        .init(
            colorScheme: .white,
            icon: .init(image: Assets.blueCircleWarning.image),
            title: Localization.mainWarningMissingDerivationTitle,
            description: Localization.mainWarningMissingDerivationDescription(numberOfNetworks),
            isDismissable: false,
            dismissAction: nil
        )
    }
}
