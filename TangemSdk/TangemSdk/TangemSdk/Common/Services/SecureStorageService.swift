//
//  SecureStorageService.swift
//  TangemSdk
//
//  Created by Alexander Osokin on 23.01.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import KeychainSwift

/// Keys used for store data in Keychain
enum StorageKey: String {
    case terminalPrivateKey //link card to terminal
    case terminalPublicKey
}

/// Helper class for Keychain
class SecureStorageService: NSObject {
    func get(key: String) -> Any? {
        let keychain = KeychainSwift()
        if let data = keychain.getData(key) {
            return NSKeyedUnarchiver.unarchiveObject(with: data)
        }
        return nil
    }
    
    func store(object: Any, key: String) {
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        let keychain = KeychainSwift()
        keychain.synchronizable = false
        keychain.set(data, forKey: key, withAccess: .accessibleWhenUnlocked)
    }
}
