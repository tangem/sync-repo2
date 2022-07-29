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

    // MARK: Root View Model

    @Published private(set) var scanCardSettingsViewModel: ScanCardSettingsViewModel?

    // MARK: Child View Models

    @Published var cardSettingsCoordinator: CardSettingsCoordinator?

    required init(
        dismissAction: @escaping Action,
        popToRootAction: @escaping ParamsAction<PopToRootOptions>
    ) {
        self.dismissAction = dismissAction
        self.popToRootAction = popToRootAction
    }

    func start(with options: Options) {
        scanCardSettingsViewModel = ScanCardSettingsViewModel(coordinator: self)
    }
}

// MARK: - Options

extension ScanCardSettingsCoordinator {
    enum Options {
        case `default`
    }
}

// MARK: - ScanCardSettingsRoutable

extension ScanCardSettingsCoordinator: ScanCardSettingsRoutable {
    func openCardSettings(cardModel: CardViewModel) {
        let coordinator = CardSettingsCoordinator(popToRootAction: self.popToRootAction)
        coordinator.start(with: .init(cardModel: cardModel))

        cardSettingsCoordinator = coordinator
    }
}
