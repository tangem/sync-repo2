//
//  VisaWalletMainContentViewModel.swift
//  Tangem
//
//  Created by Andrew Son on 13/12/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import BlockchainSdk

protocol VisaWalletRoutable: AnyObject {
    func openReceiveScreen(amountType: Amount.AmountType, blockchain: Blockchain, addressInfos: [ReceiveAddressInfo])
    func openExplorer(at url: URL, blockchainDisplayName: String)
}

class VisaWalletMainContentViewModel: ObservableObject {
    @Published var balancesAndLimitsViewModel: VisaBalancesLimitsBottomSheetViewModel? = nil

    @Published private(set) var transactionListViewState: TransactionsListView.State = .loading
    @Published private(set) var isTransactoinHistoryReloading: Bool = true
    @Published private(set) var cryptoLimitText: String = ""
    @Published private(set) var numberOfDaysLimitText: String = ""
    @Published private(set) var notificationInputs: [NotificationViewInput] = []
    @Published private(set) var failedToLoadInfoNotificationInput: NotificationViewInput?

    var isBalancesAndLimitsBlockLoading: Bool {
        cryptoLimitText.isEmpty || numberOfDaysLimitText.isEmpty
    }

    private let visaWalletModel: VisaWalletModel
    private unowned let coordinator: VisaWalletRoutable

    private var bag = Set<AnyCancellable>()
    private var updateTask: Task<Void, Never>?

    init(
        visaWalletModel: VisaWalletModel,
        coordinator: VisaWalletRoutable
    ) {
        self.visaWalletModel = visaWalletModel
        self.coordinator = coordinator

        bind()
    }

    func openDeposit() {
        Analytics.log(event: .buttonReceive, params: [.token: visaWalletModel.tokenItem.currencySymbol])

        let addressType = AddressType.default
        let addressInfo = ReceiveAddressInfo(
            address: visaWalletModel.accountAddress,
            type: addressType,
            localizedName: addressType.defaultLocalizedName,
            addressQRImage: QrCodeGenerator.generateQRCode(from: visaWalletModel.accountAddress)
        )
        coordinator.openReceiveScreen(
            amountType: visaWalletModel.tokenItem.amountType,
            blockchain: visaWalletModel.tokenItem.blockchain,
            addressInfos: [addressInfo]
        )
    }

    func openBalancesAndLimits() {
        guard
            let balances = visaWalletModel.balances,
            let limit = visaWalletModel.limits?.currentLimit
        else {
            return
        }

        balancesAndLimitsViewModel = .init(balances: balances, limit: limit)
    }

    func openExplorer() {
        guard let url = visaWalletModel.exploreURL() else {
            return
        }

        coordinator.openExplorer(at: url, blockchainDisplayName: visaWalletModel.tokenItem.blockchain.displayName)
    }

    func exploreTransaction(with id: String) {
        guard let txId = UInt64(id) else {
            return
        }

        AppLog.shared.debug("[Visa Main Content View Model] Explore transaction with id: \(id)")
    }

    func reloadTransactionHistory() {
        isTransactoinHistoryReloading = true
        visaWalletModel.reloadHistory()
    }

    func fetchNextTransactionHistoryPage() -> FetchMore? {
        guard visaWalletModel.canFetchMoreTransactionHistory else {
            return nil
        }

        return FetchMore { [weak self] in
            self?.visaWalletModel.loadNextHistoryPage()
        }
    }

    func onPullToRefresh(completionHandler: @escaping RefreshCompletionHandler) {
        guard updateTask == nil else {
            return
        }

        isTransactoinHistoryReloading = true
        updateTask = Task { [weak self] in
            await self?.visaWalletModel.generalUpdateAsync()
            self?.isTransactoinHistoryReloading = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                completionHandler()
            }
            self?.updateTask = nil
        }
    }

    private func bind() {
        visaWalletModel.walletDidChangePublisher
            .receive(on: DispatchQueue.main)
            .withWeakCaptureOf(self)
            .sink { (self, newState) in
                switch newState {
                case .loading, .notInitialized:
                    return
                case .idle:
                    self.updateLimits()
                case .failedToInitialize(let error):
                    self.failedToLoadInfoNotificationInput = NotificationsFactory().buildNotificationInput(for: error.notificationEvent)
                }
            }
            .store(in: &bag)

        visaWalletModel.transactionHistoryStatePublisher
            .receive(on: DispatchQueue.main)
            .withWeakCaptureOf(self)
            .map { viewModel, newState in
                switch newState {
                case .initial, .loading:
                    return .loading
                case .loaded:
                    viewModel.isTransactoinHistoryReloading = false
                    return .loaded(viewModel.visaWalletModel.transactionHistoryItems)
                case .failedToLoad(let error):
                    viewModel.isTransactoinHistoryReloading = false
                    return .error(error)
                }
            }
            .assign(to: \.transactionListViewState, on: self, ownership: .weak)
            .store(in: &bag)
    }

    private func updateLimits() {
        guard let limits = visaWalletModel.limits else {
            return
        }

        let balanceFormatter = BalanceFormatter()
        let currentLimit = limits.currentLimit
        let remainingSummary = (currentLimit.remainingOTPAmount ?? 0) + (currentLimit.remainingNoOTPAmount ?? 0)
        cryptoLimitText = balanceFormatter.formatCryptoBalance(remainingSummary, currencyCode: visaWalletModel.tokenItem.currencySymbol)

        let remainingTimeSeconds = Date().distance(to: currentLimit.actualExpirationDate)
        let remainingDays = Int(remainingTimeSeconds / 3600 / 24)
        numberOfDaysLimitText = "available for \(remainingDays) day(s)"
    }
}
