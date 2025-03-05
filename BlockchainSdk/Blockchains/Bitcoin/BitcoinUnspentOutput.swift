//
//  BitcoinUnspentOutput.swift
//  BlockchainSdk
//
//  Created by Andrew Son on 17/06/21.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import Foundation

@available(*, deprecated, message: "Used only for KASPA. Will be removed in https://tangem.atlassian.net/browse/IOS-9312")
struct BitcoinUnspentOutput {
    let transactionHash: String
    let outputIndex: Int
    let amount: UInt64
    let outputScript: String
}
