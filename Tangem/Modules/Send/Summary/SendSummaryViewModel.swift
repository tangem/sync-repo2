//
//  SendSummaryViewModel.swift
//  Tangem
//
//  Created by Andrey Chukavin on 30.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

protocol SendSummaryViewModelInput: AnyObject {
    var amountText: String { get }
    var canEditAmount: Bool { get }
    var canEditDestination: Bool { get }

    var destination2: AnyPublisher<String, Never> { get }
    var additionalField2: AnyPublisher<(SendAdditionalFields, String)?, Never> { get }
    var destinationTextBinding: Binding<String> { get }
    var feeTextPublisher: AnyPublisher<String?, Never> { get }

    var isSending: AnyPublisher<Bool, Never> { get }

    func send()
}

class SendSummaryViewModel: ObservableObject {
    let canEditAmount: Bool
    let canEditDestination: Bool

    let amountText: String
    let destinationText: String

    @Published var isSending = false
    @Published var feeText: String = ""

    @Published var dest: [SendDestinationSummaryViewType] = []

    let walletSummaryViewModel: SendWalletSummaryViewModel
    var amountSummaryViewData: AmountSummaryViewData

    weak var router: SendSummaryRoutable?

    private var bag: Set<AnyCancellable> = []
    private weak var input: SendSummaryViewModelInput?

    let ddd: AnyPublisher<[SendDestinationSummaryViewType], Never>
    init(input: SendSummaryViewModelInput, walletInfo: SendWalletInfo) {
        walletSummaryViewModel = SendWalletSummaryViewModel(
            walletName: walletInfo.walletName,
            totalBalance: walletInfo.balance
        )

        amountText = input.amountText

        ddd =
            .just(output: [
                SendDestinationSummaryViewType.address(address: "0x391316d97a07027a0702c8A002c8A0C25d8470"),
                SendDestinationSummaryViewType.additionalField(type: .memo, value: "123456789"),
            ])

        canEditAmount = input.canEditAmount
        canEditDestination = input.canEditDestination

        destinationText = input.destinationTextBinding.wrappedValue

        amountSummaryViewData = AmountSummaryViewData(
            title: Localization.sendAmountLabel,
            amount: "100.00 USDT",
            amountFiat: "99.98$",
            tokenIconInfo: .init(
                name: "tether",
                blockchainIconName: "ethereum.fill",
                imageURL: TokenIconURLBuilder().iconURL(id: "tether"),
                isCustom: false,
                customTokenColor: nil
            )
        )

        self.input = input

        Publishers.CombineLatest(input.destination2, input.additionalField2)
            .map {
                destination, add in

                var v: [SendDestinationSummaryViewType] = [
                    .address(address: destination),
                ]

                if let add {
                    v.append(.additionalField(type: add.0, value: add.1))
                }

                return v
            }
            .assign(to: \.dest, on: self)
            .store(in: &bag)

        bind(from: input)
    }

    func didTapSummary(for step: SendStep) {
        router?.openStep(step)
    }

    func send() {
        input?.send()
    }

    private func bind(from input: SendSummaryViewModelInput) {
        input
            .isSending
            .assign(to: \.isSending, on: self, ownership: .weak)
            .store(in: &bag)

        input
            .feeTextPublisher
            .map {
                $0 ?? ""
            }
            .assign(to: \.feeText, on: self, ownership: .weak)
            .store(in: &bag)
    }
}
