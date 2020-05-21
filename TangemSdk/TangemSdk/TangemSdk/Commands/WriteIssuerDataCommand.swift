//
//  ReadIssuerDataCommand.swift
//  TangemSdk
//
//  Created by Alexander Osokin on 19.11.2019.
//  Copyright © 2019 Tangem AG. All rights reserved.
//

import Foundation

/// Deserialized response from the Tangem card after `WriteIssuerDataCommand`.
public struct WriteIssuerDataResponse: ResponseCodable {
    /// Unique Tangem card ID number
    public let cardId: String
}

/**
 * This command writes 512-byte Issuer Data field and its issuer’s signature.
 * Issuer Data is never changed or parsed from within the Tangem COS. The issuer defines purpose of use,
 * format and payload of Issuer Data. For example, this field may contain information about
 * wallet balance signed by the issuer or additional issuer’s attestation data.
 */
@available(iOS 13.0, *)
public final class WriteIssuerDataCommand: Command {
    public typealias CommandResponse = WriteIssuerDataResponse
    /// Data provided by issuer
    public let issuerData: Data
    /**
     * Issuer’s signature of `issuerData` with `ISSUER_DATA_PRIVATE_KEY`
     * Version 1.19 and earlier:
     * Issuer’s signature of SHA256-hashed card ID concatenated with `issuerData`: SHA256(card ID | issuerData)
     * Version 1.21 and later:
     * When flag `Protect_Issuer_Data_Against_Replay` set in `SettingsMask` then signature of SHA256-hashed card ID concatenated with
     * `issuerData`  and `issuerDataCounter`: SHA256(card ID | issuerData | issuerDataCounter)
     */
    public let issuerDataSignature: Data
    /// An optional counter that protect issuer data against replay attack. When flag `Protect_Issuer_Data_Against_Replay` set in `SettingsMask`
    /// then this value is mandatory and must increase on each execution of `WriteIssuerDataCommand`.
    public let issuerDataCounter: Int?
    /**
     * - Parameters:
     *   - issuerData: Data to write
     *   - issuerDataSignature: Signature to write
     *   - issuerDataCounter: An optional counter that protect issuer data against replay attack. When flag `Protect_Issuer_Data_Against_Replay` set in `SettingsMask`
     * then this value is mandatory and must increase on each execution of `WriteIssuerDataCommand`.
     */
    
    private var issuerPublicKey: Data?
    
    public init(issuerData: Data, issuerDataSignature: Data, issuerDataCounter: Int? = nil, issuerPublicKey: Data? = nil) {
        self.issuerData = issuerData
        self.issuerDataSignature = issuerDataSignature
        self.issuerDataCounter = issuerDataCounter
        self.issuerPublicKey = issuerPublicKey
    }
    
    deinit {
        print("WriteIssuerDataCommand deinit")
    }
    
    public func run(in session: CardSession, completion: @escaping CompletionResult<WriteIssuerDataResponse>) {
        guard let card = session.environment.card else {
            completion(.failure(.missingPreflightRead))
            return
        }
        
        guard let settingsMask = card.settingsMask,
            let cardId = card.cardId else {
                completion(.failure(.cardError))
                return
        }
        
        if settingsMask.contains(.protectIssuerDataAgainstReplay) && issuerDataCounter == nil {
            completion(.failure(.missingCounter))
            return
        }
        
        if issuerPublicKey == nil {
            issuerPublicKey = session.environment.card?.issuerPublicKey
        }
        
        guard issuerPublicKey != nil else {
            completion(.failure(.missingIssuerPublicKey))
            return
        }
        
        guard verify(with: cardId) else {
            completion(.failure(.verificationFailed))
            return
        }
        
        transieve(in: session, completion: completion)
    }
    
    public func serialize(with environment: SessionEnvironment) throws -> CommandApdu {
        let tlvBuilder = try createTlvBuilder(legacyMode: environment.legacyMode)
            .append(.pin, value: environment.pin1)
            .append(.cardId, value: environment.card?.cardId)
            .append(.issuerData, value: issuerData)
            .append(.issuerDataSignature, value: issuerDataSignature)
        
        if let counter = issuerDataCounter {
            try tlvBuilder.append(.issuerDataCounter, value: counter)
        }
        
        return CommandApdu(.writeIssuerData, tlv: tlvBuilder.serialize())
    }
    
    public func deserialize(with environment: SessionEnvironment, from apdu: ResponseApdu) throws -> WriteIssuerDataResponse {
        guard let tlv = apdu.getTlvData(encryptionKey: environment.encryptionKey) else {
            throw SessionError.deserializeApduFailed
        }
        
        let decoder = TlvDecoder(tlv: tlv)
        return WriteIssuerDataResponse(cardId: try decoder.decode(.cardId))
    }
    
    private func verify(with cardId: String) -> Bool {
        return IssuerDataVerifier.verify(cardId: cardId,
                                         issuerData: issuerData,
                                         issuerDataCounter: issuerDataCounter,
                                         publicKey: issuerPublicKey!,
                                         signature: issuerDataSignature)
    }
}
