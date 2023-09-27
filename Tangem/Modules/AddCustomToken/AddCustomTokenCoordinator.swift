//
//  AddCustomTokenCoordinator.swift
//  Tangem
//
//  Created by Andrey Chukavin on 22.09.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import BlockchainSdk

class AddCustomTokenCoordinator: CoordinatorObject {
    let dismissAction: Action<Void>
    let popToRootAction: Action<PopToRootOptions>

    // MARK: - Root view model

    @Published private(set) var rootViewModel: AddCustomTokenViewModel?

    // MARK: - Child coordinators

    // MARK: - Child view models

    @Published var networkSelectorModel: AddCustomTokenNetworkSelectorViewModel?

    required init(
        dismissAction: @escaping Action<Void>,
        popToRootAction: @escaping Action<PopToRootOptions>
    ) {
        self.dismissAction = dismissAction
        self.popToRootAction = popToRootAction
    }

    func start(with options: Options) {
        rootViewModel = AddCustomTokenViewModel(settings: options.settings, userTokensManager: options.userTokensManager, coordinator: self)
    }
}

// MARK: - Options

extension AddCustomTokenCoordinator {
    struct Options {
        let settings: LegacyManageTokensSettings
        let userTokensManager: UserTokensManager
    }
}

// MARK: - AddCustomTokenRoutable

extension AddCustomTokenCoordinator: AddCustomTokenRoutable {
    func openNetworkSelector(selectedBlockchainNetworkId: String?, blockchains: [Blockchain]) {
        let networkSelectorModel = AddCustomTokenNetworkSelectorViewModel(
            selectedBlockchainNetworkId: selectedBlockchainNetworkId,
            blockchains: blockchains
        )
        networkSelectorModel.delegate = self
        self.networkSelectorModel = networkSelectorModel
    }
}

extension AddCustomTokenCoordinator: AddCustomTokenNetworkSelectorDelegate {
    func didSelectNetwork(networkId: String) {
        networkSelectorModel = nil

        rootViewModel?.setSelectedNetwork(networkId: networkId)
    }
}
