//
//  SingleWalletMainContentDelegate.swift
//  Tangem
//
//  Created by Andrey Chukavin on 26.09.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

protocol SingleWalletMainContentDelegate: AnyObject {
    func present(actionSheet: ActionSheetBinder)

    // TODO: Remove this logic after removing AlertToast - merge IOS-6500
    func displayAddressCopiedToast()
}
