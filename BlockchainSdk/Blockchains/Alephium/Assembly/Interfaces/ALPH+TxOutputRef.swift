//
//  ALPH+TxOutputRef.swift
//  BlockchainSdk
//
//  Created by Alexander Skibin on 03.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

extension ALPH {
    /// A protocol representing a transaction output reference in the Alephium blockchain
    protocol TxOutputRef: Hashable {
        /// The hint for the output reference
        var hint: Hint { get }
        /// The key for the output reference
        var key: TxOutputRefKey { get }
        /// Whether the output is an asset type
        var isAssetType: Bool { get }
        /// Whether the output is a contract type
        var isContractType: Bool { get }
    }
}
