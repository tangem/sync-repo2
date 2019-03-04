//
//  RootstockEngine.swift
//  TangemKit
//
//  Created by Gennady Berezovsky on 04.03.19.
//  Copyright © 2019 Smart Cash AG. All rights reserved.
//

import Foundation

class RootstockEngine: ETHEngine {
    
    override var walletType: WalletType {
        return .rsk
    }
    
    override var walletUnits: String {
        return card.tokenSymbol ?? "RBTC"
    }
    
    private var tokenContractAddressPrivate: String?
    public var tokenContractAddress: String? {
        set {
            tokenContractAddressPrivate = newValue
        }
        get {
            switch card.batchId {
            case 0x0019: // CLE
                return "0x0c056b0cda0763cc14b8b2d6c02465c91e33ec72"
            case 0x0017: // Qlear
                return "0x9Eef75bA8e81340da9D8d1fd06B2f313DB88839c"
            case 0x001E: // Whirl
                return "0xc6e6fbec35c866b46bbb9d4f43bbfd205944f019"
            case 0x0020: // CNS
                return "0xe961e7c13538db076b2db273cf408e4d4150fd72"
            default:
                return tokenContractAddressPrivate
            }
        }
    }
    
    override func setupAddress() {
        super.setupAddress()
        
        card.blockchainDisplayName = "Rootstock"
        card.node = "public-node.rsk.co"
        card.link = "https://explorer.rsk.co/address/" + walletAddress
    }
    
}
