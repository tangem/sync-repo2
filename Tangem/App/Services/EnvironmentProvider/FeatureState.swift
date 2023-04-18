//
//  FeatureState.swift
//  Tangem
//
//  Created by Sergey Balashov on 18.04.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

enum FeatureState: String, Hashable, Identifiable, CaseIterable, Codable {
    var id: String { rawValue }

    case `default`
    case off
    case on
}
