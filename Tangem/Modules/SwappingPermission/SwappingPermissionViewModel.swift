//
//  SwappingPermissionViewModel.swift
//  Tangem
//
//  Created by Sergey Balashov on 21.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Combine
import TangemExchange
import TangemSdk

final class SwappingPermissionViewModel: ObservableObject, Identifiable {
    /// For SwiftUI sheet logic
    let id: UUID = UUID()

    // MARK: - ViewState

    @Published var contentRowViewModels: [DefaultRowViewModel] = []

    var tokenSymbol: String {
        transactionInfo.sourceCurrency.symbol
    }

    // MARK: - Dependencies

    private let transactionInfo: ExchangeTransactionDataModel
    private let transactionSender: TransactionSenderProtocol
    private unowned let coordinator: SwappingPermissionRoutable

    init(
        transactionInfo: ExchangeTransactionDataModel,
        transactionSender: TransactionSenderProtocol,
        coordinator: SwappingPermissionRoutable
    ) {
        self.transactionInfo = transactionInfo
        self.transactionSender = transactionSender
        self.coordinator = coordinator

        setupView()
    }

    func didTapApprove() {
        Task {
            do {
                try await transactionSender.sendTransaction(transactionInfo)
                DispatchQueue.main.async {
                    self.coordinator.didSendApproveTransaction()
                }
            } catch TangemSdkError.userCancelled {
                // Do nothing
            } catch {
                assertionFailure(error.localizedDescription)
                // TODO: Show error
            }
        }
    }

    func didTapCancel() {
        coordinator.userDidCancel()
    }
}

private extension SwappingPermissionViewModel {
    func setupView() {
        /// Addresses have to the same width for both
        let walletAddress = AddressFormatter(address: transactionInfo.sourceAddress).truncated()
        let spenderAddress = AddressFormatter(address: transactionInfo.destinationAddress).truncated()

        let fee = transactionInfo.fee.groupedFormatted(
            maximumFractionDigits: transactionInfo.sourceCurrency.decimalCount
        )

        contentRowViewModels = [
            DefaultRowViewModel(title: "swapping_permission_rows_amount".localized(tokenSymbol),
                                detailsType: .icon(Assets.infinityMini)),
            DefaultRowViewModel(title: "swapping_permission_rows_your_wallet".localized,
                                detailsType: .text(String(walletAddress))),
            DefaultRowViewModel(title: "swapping_permission_rows_spender".localized,
                                detailsType: .text(String(spenderAddress))),
            DefaultRowViewModel(title: "send_fee_label".localized,
                                detailsType: .text(fee)),
        ]
    }
}
