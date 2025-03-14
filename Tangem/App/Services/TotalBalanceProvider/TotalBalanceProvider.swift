//
//  TotalBalanceProvider.swift
//  Tangem
//
//  Created by Sergey Balashov on 16.09.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import CombineExt
import TangemFoundation

class TotalBalanceProvider {
    private let userWalletId: UserWalletId
    private let walletModelsManager: WalletModelsManager
    private let derivationManager: DerivationManager?
    private let totalBalanceStateBuilder: TotalBalanceStateBuilder

    private let totalBalanceSubject: CurrentValueSubject<TotalBalanceState, Never>
    private var updateSubscription: AnyCancellable?

    init(
        userWalletId: UserWalletId,
        walletModelsManager: WalletModelsManager,
        derivationManager: DerivationManager?
    ) {
        self.userWalletId = userWalletId
        self.walletModelsManager = walletModelsManager
        self.derivationManager = derivationManager

        totalBalanceStateBuilder = .init(walletModelsManager: walletModelsManager)
        totalBalanceSubject = .init(totalBalanceStateBuilder.buildTotalBalanceState())
        bind()
    }

    deinit {
        AppLogger.debug("deinit \(self)")
    }
}

// MARK: - TotalBalanceProviding protocol conformance

extension TotalBalanceProvider: TotalBalanceProviding {
    var totalBalance: TotalBalanceState {
        totalBalanceSubject.value
    }

    var totalBalancePublisher: AnyPublisher<TotalBalanceState, Never> {
        totalBalanceSubject.eraseToAnyPublisher()
    }
}

// MARK: - Private implementation

private extension TotalBalanceProvider {
    func bind() {
        let hasEntriesWithoutDerivationPublisher = derivationManager?.hasPendingDerivations ?? .just(output: false)
        let balanceStatePublisher = walletModelsManager
            .walletModelsPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.global())
            .withWeakCaptureOf(self)
            .flatMapLatest { balanceProvider, walletModels in
                if walletModels.isEmpty {
                    return Just(TotalBalanceState.loaded(balance: 0)).eraseToAnyPublisher()
                }

                let publishers: [AnyPublisher<Void, Never>] = walletModels.map {
                    $0.fiatTotalTokenBalanceProvider
                        .balanceTypePublisher
                        .mapToVoid()
                        .eraseToAnyPublisher()
                }

                return publishers
                    // 1. Listen every change in all wallet models
                    .merge()
                    // 2. Add a small debounce to reduce the count of calculation
                    .debounce(for: 0.1, scheduler: DispatchQueue.global())
                    // 3. The latest data will be get from wallets in `totalBalanceStateBuilder`
                    // Because the data from the publishers can be outdated
                    // Why? I believe there can be race condition because
                    // `WalletModel` and `TotalBalanceProvider` working via their own background queue
                    .withWeakCaptureOf(balanceProvider)
                    .map { $0.0.totalBalanceStateBuilder.buildTotalBalanceState() }
                    .eraseToAnyPublisher()
            }

        updateSubscription = Publishers.CombineLatest(
            balanceStatePublisher,
            hasEntriesWithoutDerivationPublisher
        )
        .withWeakCaptureOf(self)
        .sink { balanceProvider, input in
            let (state, hasEntriesWithoutDerivation) = input
            balanceProvider.updateState(state: state, hasEntriesWithoutDerivation: hasEntriesWithoutDerivation)
        }
    }

    func updateState(state: TotalBalanceState, hasEntriesWithoutDerivation: Bool) {
        guard !hasEntriesWithoutDerivation else {
            totalBalanceSubject.send(.empty)
            return
        }

        totalBalanceSubject.send(state)

        // Analytics
        trackBalanceLoaded(state: state, tokensCount: walletModelsManager.walletModels.count)
        trackTokenBalanceLoaded(walletModels: walletModelsManager.walletModels)

        if case .loaded(let loadedBalance) = state {
            Analytics.logTopUpIfNeeded(balance: loadedBalance, for: userWalletId)
        }
    }

    func mapToBalanceParameterValue(state: TotalBalanceState) -> Analytics.ParameterValue? {
        switch state {
        case .empty: .noRate
        case .loading: .none
        case .failed: .blockchainError
        case .loaded(let balance) where balance > .zero: .full
        case .loaded: .empty
        }
    }

    // MARK: - Analytics

    func trackBalanceLoaded(state: TotalBalanceState, tokensCount: Int) {
        guard let balance = mapToBalanceParameterValue(state: state) else {
            return
        }

        Analytics.log(
            event: .balanceLoaded,
            params: [
                .balance: balance.rawValue,
                .tokensCount: tokensCount.description,
            ],
            limit: .userWalletSession(userWalletId: userWalletId)
        )
    }

    func trackTokenBalanceLoaded(walletModels: [WalletModel]) {
        let trackedItems = walletModels.compactMap { walletModel -> (symbol: String, balance: Decimal)? in
            switch (walletModel.tokenItem.blockchain, walletModel.fiatTotalTokenBalanceProvider.balanceType) {
            case (.polkadot, .loaded(let balance)): (symbol: walletModel.tokenItem.currencySymbol, balance: balance)
            case (.kusama, .loaded(let balance)): (symbol: walletModel.tokenItem.currencySymbol, balance: balance)
            case (.azero, .loaded(let balance)): (symbol: walletModel.tokenItem.currencySymbol, balance: balance)
            // Other don't tracking
            default: .none
            }
        }

        trackedItems.forEach { symbol, balance in
            let positiveBalance = balance > 0

            Analytics.log(
                event: .tokenBalanceLoaded,
                params: [
                    .token: symbol,
                    .state: positiveBalance ? Analytics.ParameterValue.full.rawValue : Analytics.ParameterValue.empty.rawValue,
                ],
                limit: .userWalletSession(userWalletId: userWalletId, extraEventId: symbol)
            )
        }
    }
}

// MARK: - CustomStringConvertible

extension TotalBalanceProvider: CustomStringConvertible {
    var description: String {
        TangemFoundation.objectDescription(self)
    }
}
