//
//  PlainAddress.swift
//  BlockchainSdk
//
//  Created by Sergey Balashov on 31.05.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

public struct PlainAddress: Address {
    public let value: String
    public let publicKey: Wallet.PublicKey
    public let type: AddressType

    public var localizedName: String { type.defaultLocalizedName }
}

public struct LockingScriptAddress: Address {
    public let value: String
    public let publicKey: Wallet.PublicKey
    public let type: AddressType
    public let scriptPubKey: Data

    public var localizedName: String { type.defaultLocalizedName }
}
