//
//  WalletModel+StakingWallet.swift
//  Tangem
//
//  Created by Sergey Balashov on 28.05.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation
import TangemStaking

extension WalletModel: StakingWallet {
    var stakingTokenItem: TangemStaking.StakingTokenItem {
        StakingTokenItem(network: tokenItem.networkName, contractAdress: tokenItem.contractAddress)
    }
}
