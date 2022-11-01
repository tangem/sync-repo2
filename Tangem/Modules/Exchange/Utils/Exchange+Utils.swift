//
//  Exchange+Utils.swift
//  Tangem
//
//  Created by Pavel Grechikhin on 21.10.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import Exchanger
import BlockchainSdk

extension ExchangeBlockchain {
    static func convert(from blockchainNetwork: BlockchainNetwork) -> ExchangeBlockchain {
        switch blockchainNetwork.blockchain {
        case .ethereum:
            return .ethereum
        case .binance:
            return .BSC
        case .polygon:
            return .polygon
        case .avalanche:
            return .avalanche
        case .fantom:
            return .fantom
        case .arbitrum:
            return .arbitrum
        case .optimism:
            return .optimism
        default:
            fatalError("Unknown blockchain")
        }
    }
}
