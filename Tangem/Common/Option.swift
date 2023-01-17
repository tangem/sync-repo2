//
//  Option.swift
//  Tangem
//
//  Created by Alexander Osokin on 23.11.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation

protocol Option: RawRepresentable, Hashable, CaseIterable {}

extension Set where Element: Option {
    var rawValue: Int {
        var rawValue = 0
        for (index, element) in Element.allCases.enumerated() {
            if contains(element) {
                rawValue |= (1 << index)
            }
        }

        return rawValue
    }
}
