//
//  WalletSelectorDataSource.swift
//  Tangem
//
//  Created by skibinalexander on 08.11.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine

protocol WalletSelectorDataSource: AnyObject {
    /// Published value selected UserWalletModel
    var _selectedUserWalletModel: CurrentValueSubject<UserWalletModel?, Never> { get }

    /// ViewModels list for wallet selector screen
    var itemViewModels: [WalletSelectorItemViewModel] { get }
}
