//
//  CoinModel.swift
//  Tangem
//
//  Created by Alexander Osokin on 16.03.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk
import TangemSdk

struct CoinModel {
    let id: String
    let name: String
    let symbol: String
    let items: [Item]
}

extension CoinModel {
    struct Item {
        let id: String
        let tokenItem: TokenItem
        let exchangeable: Bool

        var token: Token? { tokenItem.token }
        var blockchain: Blockchain { tokenItem.blockchain }
    }
}
