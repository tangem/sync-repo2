//
//  SwappingApprovePolicy.swift
//  TangemSwapping
//
//  Created by Sergey Balashov on 04.05.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

public enum SwappingApprovePolicy: Hashable {
    case specified(amount: Decimal)
    case unlimited

    public var amount: Decimal {
        switch self {
        case .specified(let amount):
            return amount
        case .unlimited:
            return .greatestFiniteMagnitude
        }
    }
}
