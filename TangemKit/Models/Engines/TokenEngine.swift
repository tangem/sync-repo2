//
//  TokenEngine.swift
//  TangemKit
//
//  Created by Gennady Berezovsky on 04.03.19.
//  Copyright © 2019 Smart Cash AG. All rights reserved.
//

import Foundation

class TokenEngine: ETHEngine {
    
    override var walletType: WalletType {
        
        if let symbol = card.tokenSymbol, symbol.containsIgnoringCase(find: "NFT:"){
            return .nft
        }
        
        switch card.tokenSymbol {
        case "SEED":
            return .seed
        case "QLEAR":
            return .qlear
        case "CLE":
            return .cle
        case "ERT":
            return .ert
        case "WRL":
            return .wrl
        default:
            return .eth
        }
    }
    
    public override var blockchainDisplayName: String {
        return "Ethereum smart contract token"
    }
    
    override var walletUnits: String {
        return "ETH"
    }
    
    override var exploreLink: String {
        guard let tokenContractAddress = card.tokenContractAddress else {
            return super.exploreLink
        }
        
        return "https://etherscan.io/token/\(tokenContractAddress)?a=\(walletAddress)"
    }
    
}
