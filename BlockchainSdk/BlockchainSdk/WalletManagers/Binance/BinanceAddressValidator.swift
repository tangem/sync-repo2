//
//  BinanceAddressValidator.swift
//  BlockchainSdk
//
//  Created by Alexander Osokin on 15.02.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation

public class BinanceAddressValidator {
    func validate(_ address: String, testnet: Bool) -> Bool {
        if address.isEmpty {
            return false
        }
        
        guard let _ = try? Bech32().decode(address) else {
            return false
        }
        
        if !testnet && !address.starts(with: "bnb1") {
            return false
        }
        
        if testnet && !address.starts(with: "tbnb1") {
            return false
        }
        
        return true
    }
}
