//
//  StakingWallet.swift
//  TangemStaking
//
//  Created by Sergey Balashov on 24.05.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation

public protocol StakingWallet {
    var stakingTokenItem: StakingTokenItem { get }
    var defaultAddress: String { get }
}

public struct StakingTokenItem: Hashable {
    let network: String
    let contractAdress: String?

    public init(network: String, contractAdress: String?) {
        self.network = network
        self.contractAdress = contractAdress
    }
}
