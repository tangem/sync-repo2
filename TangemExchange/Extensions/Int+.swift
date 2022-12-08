//
//  Int+.swift
//  TangemExchange
//
//  Created by Sergey Balashov on 08.12.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

extension Int {
    var decimalValue: Decimal {
        pow(10, self)
    }
}
