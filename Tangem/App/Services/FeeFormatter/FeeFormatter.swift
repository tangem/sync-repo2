//
//  FeeFormatter.swift
//  Tangem
//
//  Created by Sergey Balashov on 18.05.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import TangemExpress

protocol FeeFormatter {
    func format(fee: Decimal, tokenItem: TokenItem) -> String
    func format(fee: Decimal, currencySymbol: String, currencyId: String, isFeeApproximate: Bool) -> String
}
