//
//  AppCoordinator+SecurityManagementRoutable.swift
//  Tangem
//
//  Created by Alexander Osokin on 20.06.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

extension AppCoordinator: SecurityManagementRoutable {
    func openPinChange(with title: String, action: @escaping (@escaping (Result<Void, Error>) -> Void) -> Void) {
        cardOperationViewModel = CardOperationViewModel(title: title,
                                                        alert: "details_row_title_reset_factory_settings_warning".localized,
                                                        actionButtonPressed: action,
                                                        coordinator: self)
    }
}
