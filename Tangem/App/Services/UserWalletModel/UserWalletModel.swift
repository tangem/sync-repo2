//
//  UserWalletModel.swift
//  Tangem
//
//  Created by Sergey Balashov on 26.08.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import BlockchainSdk
import Combine

protocol UserWalletModel: CardHeaderInfoProvider, TotalBalanceProviding, AnyObject {
    var isMultiWallet: Bool { get }
    var tokensCount: Int? { get }
    var userWalletId: UserWalletId { get }
    var userWallet: UserWallet { get }
    var walletModelsManager: WalletModelsManager { get }
    var signer: TangemSigner { get }

    func initialUpdate()
    func updateWalletName(_ name: String)
}
