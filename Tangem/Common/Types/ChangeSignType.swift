//
//  ChangeSignType.swift
//  Tangem
//
//  Created by Andrey Chukavin on 12.09.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

enum ChangeSignType: Int, Hashable {
    case positive
    case negative
    case same

    var imageType: ImageType? {
        switch self {
        case .positive:
            return Assets.quotePositive
        case .negative:
            return Assets.quoteNegative
        case .same:
            return nil
        }
    }

    var textColor: Color {
        switch self {
        case .positive:
            return Colors.Text.accent
        case .negative:
            return Colors.Text.warning
        case .same:
            return Colors.Text.tertiary
        }
    }
}
