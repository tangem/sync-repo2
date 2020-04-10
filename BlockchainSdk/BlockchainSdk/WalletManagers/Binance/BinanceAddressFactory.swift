//
//  BinanceAddressFactory.swift
//  BlockchainSdk
//
//  Created by Alexander Osokin on 15.02.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk

public class BinanceAddressFactory {
    public func makeAddress(from walletPublicKey: Data, testnet: Bool) -> String {
          let compressedKey = Secp256k1Utils.convertKeyToCompressed(walletPublicKey)!
        let keyHash = RIPEMD160.hash(message: compressedKey.sha256())

        return testnet ? Bech32().encode("tbnb", values: keyHash) :
        Bech32().encode("bnb", values: keyHash)
    }
}
