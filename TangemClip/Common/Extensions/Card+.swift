//
//  Card+.swift
//  TangemClip
//
//  Created by Andrew Son on 22/03/21.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdkClips
import BlockchainSdkClips

extension Card {
    var canSign: Bool {
//        let isPin2Default = self.isPin2Default ?? true
//        let hasSmartSecurityDelay = settingsMask?.contains(.smartSecurityDelay) ?? false
//        let canSkipSD = hasSmartSecurityDelay && !isPin2Default
        
        if let fw = firmwareVersionValue, fw < 2.28 {
            if let securityDelay = pauseBeforePin2, securityDelay > 1500 {
//                && !canSkipSD {
                return false
            }
        }
        
        return true
    }
    
    var blockchain: Blockchain? {
        guard
            let name = cardData?.blockchainName,
            let curve = curve
        else { return nil }
        
        return Blockchain.from(blockchainName: name, curve: curve)
    }
    
    var isTestnet: Bool {
        return blockchain?.isTestnet ?? false
    }

    
    var cardValidationData: (cid: String, pubKey: String)? {
        guard
            let cid = cardId,
            let pubKey = cardPublicKey?.asHexString()
        else { return nil }
        
        return (cid, pubKey)
    }
}

extension Card {
    static var testCard: Card  = {
        return fromJson(testCardJson)
    }()
    
    private static func fromJson(_ json: String) -> Card {
        let jsonData = json.data(using: .utf8)!
        let decoder = JSONDecoder.tangemSdkDecoder
        do {
            let card = try decoder.decode(Card.self, from: jsonData)
            return card
        } catch {
            print(error)
        }
        fatalError()
    }
    
    private static let testCardJson =
        """
             {
               "cardData" : {
                 "batchId" : "FFFF",
                 "issuerName" : "TANGEM SDK",
                 "manufactureDateTime" : "Jan 9, 2021",
                 "manufacturerSignature" : "B906FA3D536BEFA41D7425D2FC3E96B6231FC6B50D6B50318A2E95DD39C621E11E9E3EA11C98DC39B44852778785B93EEFE1D00825632B56EBBBB111FBA6D6FD",
                "productMask" : [
                  "Note"
                ]
               },
               "cardId" : "CB42000000005343",
               "cardPublicKey" : "04B8057C3CB5C0570B1785FCEF1A0EE5CF5F3908D047126DF526261B1FBFFAC927EBE0DE837B1FACB0502D4D5D692B771EB84EBC8505AFFACB3F82381D2C8D1A26",
               "curve" : "secp256k1",
               "firmwareVersion" : {
                 "hotFix" : 0,
                 "major" : 4,
                 "minor" : 11,
                 "type" : "d SDK",
                 "version" : "4.11d SDK"
               },
               "health" : 0,
               "isActivated" : false,
               "isPin1Default" : true,
               "isPin2Default" : true,
               "issuerPublicKey" : "045F16BD1D2EAFE463E62A335A09E6B2BBCBD04452526885CB679FC4D27AF1BD22F553C7DEEFB54FD3D4F361D14E6DC3F11B7D4EA183250A60720EBDF9E110CD26",
               "manufacturerName" : "TANGEM",
               "pauseBeforePin2" : 500,
               "pin2IsDefault" : true,
               "settingsMask" : [
                 "IsReusable",
                 "AllowSetPIN1",
                 "AllowSetPIN2",
                 "UseNDEF",
                 "AllowUnencrypted",
                 "AllowFastEncryption",
                 "ProtectIssuerDataAgainstReplay",
                 "AllowSelectBlockchain",
                 "DisablePrecomputedNDEF",
                 "SkipSecurityDelayIfValidatedByLinkedTerminal",
                 "RestrictOverwriteIssuerExtraData"
               ],
               "signingMethods" : [
                 "SignHash"
               ],
               "status" : "Empty",
               "terminalIsLinked" : false,
               "walletIndex" : 0,
               "wallets" : {
                 "0" : {
                   "index" : 0,
                   "status" : "Empty"
                 },
                 "1" : {
                   "index" : 1,
                   "status" : "Empty"
                 },
                 "2" : {
                   "index" : 2,
                   "status" : "Empty"
                 },
                 "3" : {
                   "index" : 3,
                   "status" : "Empty"
                 },
                 "4" : {
                   "index" : 4,
                   "status" : "Empty"
                 }
               },
               "walletsCount" : 5
             }
    """
}
