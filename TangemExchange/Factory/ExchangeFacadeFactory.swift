//
//  ExchangeProviderFactory.swift
//  Tangem
//
//  Created by Pavel Grechikhin on 08.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

class ExchangeProviderFactory {
    enum Router {
        case oneInch
    }

    func createFacade(for router: Router, exchangeManager: ExchangeManager, signer: TangemSigner, blockchainNetwork: BlockchainNetwork) -> ExchangeProvider {
        switch router {
        case .oneInch:
            return ExchangeOneInchProvider(exchangeManager: exchangeManager, signer: signer, blockchainNetwork: blockchainNetwork)
        }
    }
}
