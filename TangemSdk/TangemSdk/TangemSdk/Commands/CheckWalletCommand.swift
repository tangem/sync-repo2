//
//  CheckWalletCommand.swift
//  TangemSdk
//
//  Created by Alexander Osokin on 03/10/2019.
//  Copyright © 2019 Tangem AG. All rights reserved.
//

import Foundation

/// Deserialized response from the Tangem card after `CheckWalletCommand`.
public struct CheckWalletResponse: ResponseCodable {
    /// Unique Tangem card ID number
    public let cardId: String
    /// Random salt generated by the card
    public let salt: Data
    /// Challenge and salt signed with the wallet private key.
    public let walletSignature: Data
}

/// This command proves that the wallet private key from the card corresponds to the wallet public key.  Standard challenge/response scheme is used
@available(iOS 13.0, *)
public final class CheckWalletCommand: Command {
    deinit {
         print("CheckWalletCommand deinit")
    }
    
    public typealias CommandResponse = CheckWalletResponse
    /// Random challenge generated by application
    private let challenge: Data
    private let curve: EllipticCurve
    private let publicKey: Data
    
    public init?(curve: EllipticCurve, publicKey: Data) {
        self.curve = curve
        self.publicKey = publicKey
        
        if let challenge = CryptoUtils.generateRandomBytes(count: 16) {
            self.challenge = challenge
        } else {
            return nil
        }
    }
    public func run(in session: CardSession, completion: @escaping CompletionResult<CheckWalletResponse>) {
        transieve(in: session) {result in
            switch result {
            case .success(let checkWalletResponse):
                guard let verifyResult = self.verify(response: checkWalletResponse) else {
                    completion(.failure(.cryptoUtilsError))
                    return
                }
                
                if verifyResult {
                    completion(.success(checkWalletResponse))
                } else {
                    completion(.failure(.verificationFailed))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func serialize(with environment: SessionEnvironment) throws -> CommandApdu {
        let tlvBuilder = try createTlvBuilder(legacyMode: environment.legacyMode)
            .append(.pin, value: environment.pin1)
            .append(.cardId, value: environment.card?.cardId)
            .append(.challenge, value: challenge)
        
        return CommandApdu(.checkWallet, tlv: tlvBuilder.serialize())
    }
    
    public func deserialize(with environment: SessionEnvironment, from apdu: ResponseApdu) throws -> CheckWalletResponse {
        guard let tlv = apdu.getTlvData(encryptionKey: environment.encryptionKey) else {
            throw SessionError.deserializeApduFailed
        }
        
        let decoder = TlvDecoder(tlv: tlv)
        return CheckWalletResponse(
            cardId: try decoder.decode(.cardId),
            salt: try decoder.decode(.salt),
            walletSignature: try decoder.decode(.walletSignature))
    }
    
    private func verify(response: CheckWalletResponse) -> Bool? {
        return CryptoUtils.vefify(curve: curve,
                                  publicKey: publicKey,
                                  message: challenge + response.salt,
                                  signature: response.walletSignature)
    }
}
