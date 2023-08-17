//
//  TokenItemsRepository.swift
//  Tangem
//
//  Created by Andrey Fedorov on 12.08.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

protocol TokenItemsRepository {
    var isInitialized: Bool { get }

    func update(_ tokens: [StorageEntry.V3.Entry])
    func append(_ tokens: [StorageEntry.V3.Entry])
    func remove(_ tokens: [StorageEntry.V3.Entry])
    func remove(_ blockchainNetworks: [StorageEntry.V3.BlockchainNetwork])
    func removeAll()

    func getItems() -> [StorageEntry.V3.Entry]
}
