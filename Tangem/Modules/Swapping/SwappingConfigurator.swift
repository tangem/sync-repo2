//
//  SwappingConfigurator.swift
//  Tangem
//
//  Created by Sergey Balashov on 28.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import TangemExchange

import protocol BlockchainSdk.TransactionSigner

struct SwappingConfigurator {
    func createModule(input: InputModel, coordinator: SwappingRoutable) -> SwappingViewModel {
        let exchangeManager = DependenciesFactory().createExchangeManager(
            walletModel: input.walletModel,
            signer: input.signer,
            source: input.source,
            destination: input.destination
        )

        return SwappingViewModel(exchangeManager: exchangeManager, coordinator: coordinator)
    }
}

extension SwappingConfigurator {
    struct InputModel {
        let walletModel: WalletModel
        let signer: TransactionSigner
        let source: Currency
        let destination: Currency
    }
}
