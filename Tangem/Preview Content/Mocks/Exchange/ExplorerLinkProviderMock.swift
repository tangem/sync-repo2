//
//  ExplorerLinkProviderMock.swift
//  Tangem
//
//  Created by Sergey Balashov on 31.01.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import TangemExchange

struct ExplorerLinkProviderMock: ExplorerLinkProviding {
    func getExplorerLink(for blockchain: ExchangeBlockchain, transaction: String) -> URL? {
        nil
    }
}
