//
//  UserTokensManagerMock.swift
//  Tangem
//
//  Created by Alexander Osokin on 30.06.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
import BlockchainSdk

struct UserTokensManagerMock: UserTokensManager {
    func add(_ tokenItems: [TokenItem], derivationPath: DerivationPath?, completion: @escaping (Result<Void, TangemSdkError>) -> Void) {}

    func add(_ tokenItem: TokenItem, derivationPath: DerivationPath?, completion: @escaping (Result<Void, TangemSdkError>) -> Void) {}

    func contains(_ tokenItem: TokenItem, derivationPath: DerivationPath?) -> Bool {
        return false
    }

    func getAllTokens(for blockchainNetwork: BlockchainNetwork) -> [Token] {
        []
    }

    func canRemove(_ tokenItem: TokenItem, derivationPath: DerivationPath?) -> Bool {
        return false
    }

    func remove(_ tokenItem: TokenItem, derivationPath: DerivationPath?) {}
}
