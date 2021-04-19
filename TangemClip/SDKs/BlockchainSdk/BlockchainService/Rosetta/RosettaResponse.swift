//
//  RosettaResponse.swift
//  BlockchainSdk
//
//  Created by Andrew Son on 19/03/21.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import Foundation

struct RosettaBalanceResponse: Codable {
    let balances: [RosettaAmount]
    let coins: [RosettaCoin]
    
    var address: String?
}

struct RosettaSubmitResponse: Codable {
    let transactionIdentifier: RosettaTransactionIdentifier
}
