//
//  MainHeaderBalanceProviderFactory.swift
//  Tangem
//
//  Created by Andrew Son on 14/12/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine

struct MainHeaderBalanceProviderFactory {
    func provider(for model: UserWalletModel) -> MainHeaderBalanceProvider {
        return CommonMainHeaderBalanceProvider(
            totalBalanceProvider: model,
            userWalletStateInfoProvider: model,
            mainBalanceFormatter: CommonMainHeaderBalanceFormatter()
        )
    }
}
