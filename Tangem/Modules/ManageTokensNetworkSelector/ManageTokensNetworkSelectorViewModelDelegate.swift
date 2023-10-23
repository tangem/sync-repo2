//
//  ManageTokensNetworkSelectorViewModelDelegate.swift
//  Tangem
//
//  Created by skibinalexander on 23.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

protocol ManageTokensNetworkSelectorViewModelDelegate: AnyObject {
    func tokenItemsDidUpdate(by coinId: String)
}
