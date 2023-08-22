//
//  OrganizeTokensOptions.swift
//  Tangem
//
//  Created by Andrey Fedorov on 04.08.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

enum OrganizeTokensOptions {
    typealias Grouping = StorageEntry.V3.Grouping
    typealias Sorting = StorageEntry.V3.Sorting
}

// MARK: - Convenience extensions

extension OrganizeTokensOptions.Grouping {
    var isGrouped: Bool {
        switch self {
        case .none:
            return false
        case .byBlockchainNetwork:
            return true
        }
    }
}

extension OrganizeTokensOptions.Sorting {
    var isSorted: Bool {
        switch self {
        case .manual:
            return false
        case .byBalance:
            return true
        }
    }
}
