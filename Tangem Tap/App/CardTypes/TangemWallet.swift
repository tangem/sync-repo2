//
//  TangemWallet.swift
//  Tangem Tap
//
//  Created by Andrew Son on 04/08/21.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import Foundation

enum TangemWallet: String {
    case multiwalletV4 = "AC01"
    
    static func isWalletBatch(_ batch: String) -> Bool {
        TangemWallet(rawValue: batch) != nil
    }
}
