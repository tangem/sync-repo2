//
//  UnsignedTransaction.swift
//  HDWalletKit
//
//  Created by Pavlo Boiko on 2/17/19.
//  Copyright © 2019 Essentia. All rights reserved.
//

import Foundation

public struct UnsignedTransaction {
    public let tx: HDTransaction
    public let utxos: [HDUnspentTransaction]
    
    public init(tx: HDTransaction, utxos: [HDUnspentTransaction]) {
        self.tx = tx
        self.utxos = utxos
    }
}
