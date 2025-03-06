//
//  WalletModelsManagerMock.swift
//  Tangem
//
//  Created by Alexander Osokin on 30.06.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine

struct WalletModelsManagerMock: WalletModelsManager {
    var isInitialized: Bool { true }
    var walletModels: [any WalletModel] { [] }
    var walletModelsPublisher: AnyPublisher<[any WalletModel], Never> { .just(output: []) }

    func updateAll(silent: Bool, completion: @escaping () -> Void) {}
}
