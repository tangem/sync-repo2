//
//  BlockchainItem.swift
//  Tangem
//
//  Created by Andrey Chukavin on 28.03.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import BlockchainSdk
import TangemSdk

struct BlockchainInfo: Codable, Hashable {
    let blockchain: Blockchain
    let derivationPath: DerivationPath?
}

extension BlockchainInfo {
    init(blockchain: Blockchain) {
        self.blockchain = blockchain
        self.derivationPath = nil
    }
}
