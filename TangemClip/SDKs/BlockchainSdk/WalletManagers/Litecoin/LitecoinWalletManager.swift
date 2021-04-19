//
//  LitecoinWalletManager.swift
//  BlockchainSdk
//
//  Created by Alexander Osokin on 31.01.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import Combine

class LitecoinWalletManager: BitcoinWalletManager {
    override var relayFee: Decimal? {
        return Decimal(0.00001)
    }
}
