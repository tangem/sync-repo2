//
//  KeysRepository.swift
//  Tangem
//
//  Created by Alexander Osokin on 20.06.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

protocol KeysRepository: AnyObject, KeysProvider {
    func update(keys: [CardDTO.Wallet])
}

protocol KeysProvider {
    var keys: [CardDTO.Wallet] { get }
}

class CommonKeysRepository {
    private(set) var keys: [CardDTO.Wallet]

    init(with keys: [CardDTO.Wallet]) {
        self.keys = keys
    }
}

extension CommonKeysRepository: KeysRepository {
    func update(keys: [CardDTO.Wallet]) {
        self.keys = keys
    }
}
