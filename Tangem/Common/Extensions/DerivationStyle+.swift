//
//  DerivationStyle+.swift
//  Tangem
//
//  Created by Alexander Osokin on 30.03.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk

extension DerivationStyle {
    init(with batchId: String) {
        let batchId = batchId.uppercased()
        
        if batchId == "AC01" || batchId == "AC02" {
            self = .legacy
        }
        
        self = .new
    }
}
