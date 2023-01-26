//
//  SwappingSuccessInputModel.swift
//  Tangem
//
//  Created by Sergey Balashov on 13.01.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

struct SwappingSuccessInputModel {
    let sourceCurrencyAmount: CurrencyAmount
    let resultCurrencyAmount: CurrencyAmount
    let explorerURL: URL?
}
