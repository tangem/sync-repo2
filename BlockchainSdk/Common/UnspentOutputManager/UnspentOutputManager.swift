//
//  UnspentOutputManager.swift
//  TangemApp
//
//  Created by Sergey Balashov on 24.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

protocol UnspentOutputManager {
    func update(outputs: [UnspentOutput], for script: Data)
    func outputs(for amount: UInt64, script: Data) throws -> [UnspentOutput]

    func allOutputs() -> [ScriptUnspentOutput]

    func confirmedBalance() -> UInt64
    func unconfirmedBalance() -> UInt64
}

extension UnspentOutputManager {
    func update(outputs: [UnspentOutput], for address: LockingScriptAddress) {
        update(outputs: outputs, for: address.scriptPubKey)
    }
}
