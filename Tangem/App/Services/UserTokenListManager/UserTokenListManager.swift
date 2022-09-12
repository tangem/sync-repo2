//
//  UserTokenListManager.swift
//  Tangem
//
//  Created by Sergey Balashov on 17.08.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Combine
import BlockchainSdk

protocol UserTokenListManager {
    func update(userWalletId: Data)
    func update(_ type: CommonUserTokenListManager.UpdateType, result: @escaping (Result<UserTokenList, Error>) -> Void)

    func loadAndSaveUserTokenList(result: @escaping (Result<UserTokenList, Error>) -> Void)
    func getEntriesFromRepository() -> [StorageEntry]
    func clearRepository(result: @escaping (Result<UserTokenList, Error>) -> Void)
}
