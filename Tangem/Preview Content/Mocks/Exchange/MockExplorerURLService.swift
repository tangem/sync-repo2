//
//  MockExplorerURLService.swift
//  Tangem
//
//  Created by Sergey Balashov on 31.01.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import TangemExchange

struct MockExplorerURLService: ExplorerURLService {
    func getExplorerURL(for blockchain: ExchangeBlockchain, transactionID: String) -> URL? {
        nil
    }
}
