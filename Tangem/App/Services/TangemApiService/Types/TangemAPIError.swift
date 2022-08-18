//
//  TangemAPIError.swift
//  Tangem
//
//  Created by Sergey Balashov on 17.08.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

enum TangemAPIError: Error {
    case statusCode(_ code: Int)
}

extension TangemAPIError {
    var statusCode: Int? {
        if case let .statusCode(code) = self {
            return code
        }

        return nil
    }
}
