//
//  ExplorerURLService.swift
//  Tangem
//
//  Created by Sergey Balashov on 01.02.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import TangemExchange

protocol ExplorerURLService {
    func getExplorerURL(for blockchain: ExchangeBlockchain, transactionID: String) -> URL?
}
