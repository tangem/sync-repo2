//
//  FileEncryptionUtility.swift
//  Tangem
//
//  Created by Andrew Son on 28/06/21.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import Foundation
import CryptoKit
import TangemSdk

class FileEncryptionUtility {
    private let keychain: SecureStorage = .init()

    init() {}

    private var keychainKey: String { "tangem_files_symmetric_key" }

    func encryptData(_ data: Data) throws -> Data {
        let sealedBox = try ChaChaPoly.seal(data, using: try storedSymmetricKey())
        let sealedData = sealedBox.combined
        return sealedData
    }

    func decryptData(_ data: Data) throws -> Data {
        let sealedBox = try ChaChaPoly.SealedBox(combined: data)
        let decryptedData = try ChaChaPoly.open(sealedBox, using: try storedSymmetricKey())
        return decryptedData
    }

    private func storedSymmetricKey() throws -> SymmetricKey {
        if let key = try keychain.get(keychainKey) {
            let symmetricKey: SymmetricKey = .init(data: key)
            return symmetricKey
        }

        let key = SymmetricKey(size: .bits256)
        try keychain.store(key.dataRepresentation, forKey: keychainKey)
        return key
    }
}

extension ContiguousBytes {
    /// A Data instance created safely from the contiguous bytes without making any copies.
    var dataRepresentation: Data {
        return self.withUnsafeBytes { bytes in
            let cfdata = CFDataCreateWithBytesNoCopy(nil, bytes.baseAddress?.assumingMemoryBound(to: UInt8.self), bytes.count, kCFAllocatorNull)
            return ((cfdata as NSData?) as Data?) ?? Data()
        }
    }
}
