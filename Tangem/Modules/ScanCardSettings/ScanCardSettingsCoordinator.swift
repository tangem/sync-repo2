//
//  ScanCardSettingsCoordinator.swift
//  Tangem
//
//  Created by Sergey Balashov on 26.07.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Combine
import Foundation

class ScanCardSettingsCoordinator: CoordinatorObject {
    var dismissAction: Action
    var popToRootAction: ParamsAction<PopToRootOptions>

    // MARK: - Main view model

    @Published private(set) var rootViewModel: ScanCardSettingsViewModel?

    required init(
        dismissAction: @escaping Action,
        popToRootAction: @escaping ParamsAction<PopToRootOptions>
    ) {
        self.dismissAction = dismissAction
        self.popToRootAction = popToRootAction
    }

    func start(with options: Options) {
        rootViewModel = ScanCardSettingsViewModel(coordinator: self)
    }
}

// MARK: - Options

extension ScanCardSettingsCoordinator {
    struct Options {
        let cardModel: CardViewModel
    }
}

// MARK: - ScanCardSettingsRoutable

extension ScanCardSettingsCoordinator: ScanCardSettingsRoutable {}
