//
//  SwappingRoutable.swift
//  Tangem
//
//  Created by Sergey Balashov on 18.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

protocol SwappingRoutable: AnyObject {
    func presentSuccessView(fromCurrency: String, toCurrency: String)
    func presentExchangeableTokenListView(inputModel: SwappingPermissionViewModel.InputModel)
}
