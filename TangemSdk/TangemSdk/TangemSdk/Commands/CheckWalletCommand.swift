//
//  CheckWalletCommand.swift
//  TangemSdk
//
//  Created by Alexander Osokin on 03/10/2019.
//  Copyright © 2019 Tangem AG. All rights reserved.
//

import Foundation

/// Deserialized response from the Tangem card after `CheckWalletCommand`.
public struct CheckWalletResponse {
    /// Unique Tangem card ID number
    public let cardId: String
    /// Random salt generated by the card
    public let salt: Data
    /// Challenge and salt signed with the wallet private key.
    public let walletSignature: Data
}

/// This command proves that the wallet private key from the card corresponds to the wallet public key.  Standard challenge/response scheme is used
@available(iOS 13.0, *)
public final class CheckWalletCommand: CommandSerializer {
    public typealias CommandResponse = CheckWalletResponse
    /// Unique Tangem card ID number
    let cardId: String
    /// Random challenge generated by application
    let challenge: Data
    
    public init(cardId: String, challenge: Data) {
        self.cardId = cardId
        self.challenge = challenge
    }
    
    public func serialize(with environment: CardEnvironment) -> CommandApdu {
        let tlvData = [Tlv(.pin, value: environment.pin1.sha256()),
                       Tlv(.cardId, value: Data(hexString: cardId)),
                       Tlv(.challenge, value: challenge)]
        
        let cApdu = CommandApdu(.checkWallet, tlv: tlvData)
        return cApdu
    }
    
    public func deserialize(with environment: CardEnvironment, from responseApdu: ResponseApdu) throws -> CheckWalletResponse {
        guard let tlv = responseApdu.getTlvData(encryptionKey: environment.encryptionKey) else {
            throw TaskError.serializeCommandError
        }
        
        let mapper = TlvMapper(tlv: tlv)
        return CheckWalletResponse(
            cardId: try mapper.map(.cardId),
            salt: try mapper.map(.salt),
            walletSignature: try mapper.map(.walletSignature))
    }
}
