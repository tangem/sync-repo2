//
//  SendAdditionalFields.swift
//  Tangem Tap
//
//  Created by Andrew Son on 17/12/20.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
import BlockchainSdk

enum SendAdditionalFields {
    case memo, destinationTag, none
    
    static func fields(for cardInfo: CardInfo) -> SendAdditionalFields {
        guard let blockchain = cardInfo.defaultBlockchain else { return .none }
        
        switch blockchain {
        case .stellar:
            return .memo
        case .xrp:
            return .destinationTag
        default:
            return .none
        }
    }
}
