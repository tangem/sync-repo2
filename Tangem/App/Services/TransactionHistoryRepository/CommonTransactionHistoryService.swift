//
//  CommonTransactionHistoryService.swift
//  Tangem
//
//  Created by Sergey Balashov on 04.08.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk
import Combine
import class TangemExpress.ThreadSafeContainer

class CommonTransactionHistoryService {
    private let tokenItem: TokenItem
    private let address: String

    private let transactionHistoryProvider: TransactionHistoryProvider

    private var _state = CurrentValueSubject<TransactionHistoryServiceState, Never>(.initial)
    private var totalPages: Int?
    private var currentPage: TransactionHistoryPage?
    private let pageSize: Int = 20
    private var cancellable: AnyCancellable?
    private var storage: ThreadSafeContainer<[TransactionRecord]> = []

    init(
        tokenItem: TokenItem,
        address: String,
        transactionHistoryProvider: TransactionHistoryProvider
    ) {
        self.tokenItem = tokenItem
        self.address = address
        self.transactionHistoryProvider = transactionHistoryProvider
    }
}

// MARK: - TransactionHistoryService

extension CommonTransactionHistoryService: TransactionHistoryService {
    var state: TransactionHistoryServiceState {
        _state.value
    }

    var statePublisher: AnyPublisher<TransactionHistoryServiceState, Never> {
        _state.eraseToAnyPublisher()
    }

    var items: [TransactionRecord] {
        return storage.read()
    }

    var canFetchHistory: Bool {
        return currentPage?.canFetchMore ?? false
    }

    func clearHistory() {
        cancellable = nil
        currentPage = nil
        totalPages = nil
        cleanStorage()
        AppLog.shared.debug("\(self) was reset")
    }

    func update() -> AnyPublisher<Void, Never> {
        Deferred {
            Future { [weak self] promise in
                self?.fetch(result: promise)
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Private

private extension CommonTransactionHistoryService {
    func fetch(result: @escaping (Result<Void, Never>) -> Void) {
        cancellable = nil

        guard currentPage == nil || canFetchHistory else {
            AppLog.shared.debug("\(self) reached the end of list")
            result(.success(()))
            return
        }

        AppLog.shared.debug("\(self) start loading")
        _state.send(.loading)

        let page = TransactionHistoryPage(limit: pageSize, page: currentPage?.nextPage)
        let request = TransactionHistory.Request(address: address, amountType: tokenItem.amountType, page: page)

        cancellable = transactionHistoryProvider
            .loadTransactionHistory(request: request)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?._state.send(.failedToLoad(error))
                    AppLog.shared.debug("\(String(describing: self)) error: \(error)")
                    result(.success(()))
                case .finished:
                    self?._state.send(.loaded)
                }
            } receiveValue: { [weak self] response in
                self?.totalPages = response.totalPages
                self?.currentPage = response.page
                self?.addToStorage(records: response.records)
                AppLog.shared.debug("\(String(describing: self)) loaded")
                result(.success(()))
            }
    }

    func cleanStorage() {
        storage.mutate { value in
            value.removeAll()
        }
    }

    func addToStorage(records: [TransactionRecord]) {
        storage.mutate { value in
            value += records
        }
    }
}

// MARK: - CustomStringConvertible

extension CommonTransactionHistoryService: CustomStringConvertible {
    var description: String {
        objectDescription(
            self,
            userInfo: [
                "name": tokenItem.name,
                "type": tokenItem.isToken ? "Token" : "Coin",
                "address": address,
                "totalPages": totalPages ?? "-",
                "currentPage": currentPage ?? "-",
                "nextPage": currentPage?.nextPage ?? "-",
            ]
        )
    }
}
