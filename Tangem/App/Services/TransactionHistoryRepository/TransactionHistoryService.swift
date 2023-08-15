//
//  TransactionHistoryService.swift
//  Tangem
//
//  Created by Sergey Balashov on 15.08.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

protocol TransactionHistoryService: AnyObject {
    var canFetchMore: Bool { get }

    var state: TransactionHistoryServiceState { get }
    var statePublisher: AnyPublisher<TransactionHistoryServiceState, Never> { get }

    var items: [TransactionRecord] { get }

    /// Use this method for reset manager to first page
    func reset()

    /// Use this method for reset manager to first page
    func update() -> AnyPublisher<Void, Error>
}
