//
//  CommonStakingRepository.swift
//  Tangem
//
//  Created by Sergey Balashov on 28.05.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import TangemStaking

struct CommonStakingRepositoryProxy {
    private let repository: StakingRepository

    init() {
        let provider = StakingDependenciesFactory().makeStakingAPIProvider()
        repository = TangemStakingFactory().makeStakingRepository(provider: provider, logger: AppLog.shared)
    }
}

extension CommonStakingRepositoryProxy: StakingRepository {
    var enabledYieldsPuiblisher: AnyPublisher<[YieldInfo], Never> {
        repository.enabledYieldsPuiblisher
    }

    func updateEnabledYields(withReload: Bool) {
        repository.updateEnabledYields(withReload: withReload)
    }

    func getYield(id: String) -> YieldInfo? {
        repository.getYield(id: id)
    }

    func getYield(item: StakingTokenItem) -> YieldInfo? {
        repository.getYield(item: item)
    }
}

extension CommonStakingRepositoryProxy: Initializable {
    func initialize() {
        repository.updateEnabledYields(withReload: true)
    }
}
