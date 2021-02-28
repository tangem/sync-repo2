//
//  Blockchain+.swift
//  Tangem Tap
//
//  Created by Alexander Osokin on 28.02.2021.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk

extension Blockchain: Identifiable {
    public var id: Int { return hashValue }
}
