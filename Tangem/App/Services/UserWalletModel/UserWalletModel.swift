//
//  UserWalletModel.swift
//  Tangem
//
//  Created by Sergey Balashov on 26.08.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import BlockchainSdk
import Combine

protocol UserWalletModel: AnyObject {
    /// Public until managers factory
    var userTokenListManager: UserTokenListManager { get }
    var totalBalanceProvider: TotalBalanceProviding { get }
    var userWallet: UserWallet { get }

    func getWalletModels() -> [WalletModel]
    func subscribeToWalletModels() -> AnyPublisher<[WalletModel], Never>

    func getSavedEntries() -> [StorageEntry]
    func getEntriesWithoutDerivation() -> [StorageEntry]
    func subscribeToEntriesWithoutDerivation() -> AnyPublisher<[StorageEntry], Never>

    func canManage(amountType: Amount.AmountType, blockchainNetwork: BlockchainNetwork) -> Bool
    func update(entries: [StorageEntry])
    func append(entries: [StorageEntry])
    func remove(item: RemoveItem)

    /// Update if the wallet model hasn't initial updates
    func initialUpdate()
    func updateWalletModels()
    func updateAndReloadWalletModels(silent: Bool, completion: @escaping () -> Void)
}

extension UserWalletModel {
    func updateAndReloadWalletModels(completion: @escaping () -> Void) {
        updateAndReloadWalletModels(silent: false, completion: completion)
    }

    func updateAndReloadWalletModels() {
        updateAndReloadWalletModels(silent: false, completion: {})
    }
}

struct RemoveItem {
    let amount: Amount.AmountType
    let blockchainNetwork: BlockchainNetwork
}
