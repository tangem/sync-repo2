//
//  LockedWalletModelsManager.swift
//  Tangem
//
//  Created by Andrew Son on 28/07/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine

struct LockedWalletModelsManager: WalletModelsManager {
    var isInitialized: Bool { true }
    var walletModels: [any WalletModel] { [] }
    var walletModelsPublisher: AnyPublisher<[any WalletModel], Never> { .just(output: []) }

    func updateAll(silent: Bool, completion: @escaping () -> Void) {
        completion()
    }
}
