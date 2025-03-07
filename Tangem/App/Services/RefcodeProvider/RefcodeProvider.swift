//
//  RefcodeProvider.swift
//  Tangem
//
//  Created by Alexander Skibin on 25.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

enum Refcode: String, CaseIterable {
    case ring
    case partner
    case changeNow = "ChangeNow"
}

protocol RefcodeProvider {
    func getRefcode() -> Refcode?
}
