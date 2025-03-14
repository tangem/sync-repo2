//
//  HotCryptoAddToPortfolioModel.swift
//  TangemApp
//
//  Created by GuitarKitty on 16.01.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk

struct HotCryptoAddToPortfolioModel: Identifiable {
    let id = UUID()
    let token: HotCryptoToken
    let userWalletName: String
    let tokenNetworkName: String
    let tokenIconInfo: TokenIconInfo?

    init(token: HotCryptoToken, userWalletName: String) {
        self.token = token
        self.userWalletName = userWalletName
        tokenIconInfo = token.tokenIconInfo
        tokenNetworkName = token.tokenItem?.blockchain.displayName ?? ""
    }
}
