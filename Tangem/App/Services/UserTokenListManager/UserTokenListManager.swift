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
    func update(userWalletId: String)

    func update(entries: [StorageEntry], result: @escaping (Result<UserTokenList, Error>) -> Void)
    func append(entries: [StorageEntry], result: @escaping (Result<UserTokenList, Error>) -> Void)
    func remove(blockchain: BlockchainNetwork, result: @escaping (Result<UserTokenList, Error>) -> Void)
    func remove(tokens: [Token], in blockchain: BlockchainNetwork, result: @escaping (Result<UserTokenList, Error>) -> Void)

    func loadAndSaveUserTokenList() -> AnyPublisher<UserTokenList, Error>
    func getEntriesFromRepository() -> [StorageEntry]
    func clearRepository(result: @escaping (Result<UserTokenList, Error>) -> Void)
}
