//
//  SendFeeViewModel.swift
//  Tangem
//
//  Created by Andrey Chukavin on 30.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import BigInt
import BlockchainSdk

protocol SendFeeViewModelInput {
    var selectedFeeOption: FeeOption { get }
    var feeOptions: [FeeOption] { get }
    var feeValues: AnyPublisher<[FeeOption: LoadingValue<Fee>], Never> { get }

    var customGasPricePublisher: AnyPublisher<BigUInt?, Never> { get }
//    var gasLimitPublisher: AnyPublisher<BigUInt, Never> { get }

    func didSelectFeeOption(_ feeOption: FeeOption)

    func didChangeCustomFeeGasPrice(_ value: BigUInt?)
}

class SendFeeViewModel: ObservableObject {
    @Published private(set) var selectedFeeOption: FeeOption
    @Published private(set) var feeRowViewModels: [FeeRowViewModel] = []
    @Published private(set) var showCustomFeeFields: Bool = false

    let customFeeModel: SendCustomFeeInputFieldModel?
    let customFeeGasPriceModel: SendCustomFeeInputFieldModel?
    let customFeeGasLimitModel: SendCustomFeeInputFieldModel?

    private let input: SendFeeViewModelInput
    private let feeOptions: [FeeOption]
    private let walletInfo: SendWalletInfo
    private var bag: Set<AnyCancellable> = []

    private var feeFormatter: FeeFormatter {
        CommonFeeFormatter(
            balanceFormatter: BalanceFormatter(),
            balanceConverter: BalanceConverter()
        )
    }

    init(input: SendFeeViewModelInput, walletInfo: SendWalletInfo) {
        self.input = input
        self.walletInfo = walletInfo
        feeOptions = input.feeOptions
        selectedFeeOption = input.selectedFeeOption

        if feeOptions.contains(.custom) {
            customFeeModel = SendCustomFeeInputFieldModel(
                title: Localization.sendMaxFee,
                amountPublisher: .just(output: .internal(1234)),
                fractionDigits: 0,
                amountAlternativePublisher: .just(output: "0.41 $"),
                footer: Localization.sendMaxFeeFooter
            ) { enteredValue in
                let gasPrice: BigUInt?

                if let decimalValue = enteredValue?.value {
                    gasPrice = EthereumUtils.mapToBigUInt(decimalValue)
                } else {
                    gasPrice = nil
                }
                input.didChangeCustomFeeGasPrice(gasPrice)
            }

            customFeeGasPriceModel = SendCustomFeeInputFieldModel(
                title: Localization.sendGasPrice,
                amountPublisher: .just(output: .internal(1234)),
                fractionDigits: 0,
                amountAlternativePublisher: .just(output: nil),
                footer: Localization.sendGasPriceFooter
            ) { value in
            }

            customFeeGasLimitModel = SendCustomFeeInputFieldModel(
                title: Localization.sendGasLimit,
                amountPublisher: .just(output: .internal(1234)),
                fractionDigits: 0,
                amountAlternativePublisher: .just(output: nil),
                footer: Localization.sendGasLimitFooter
            ) { value in
            }

        } else {
            customFeeModel = nil
            customFeeGasPriceModel = nil
            customFeeGasLimitModel = nil
        }

        feeRowViewModels = makeFeeRowViewModels([:])

        bind()
    }

    private func bind() {
        input.feeValues
            .sink { [weak self] feeValues in
                guard let self else { return }
                feeRowViewModels = makeFeeRowViewModels(feeValues)
            }
            .store(in: &bag)
    }

    private func makeFeeRowViewModels(_ feeValues: [FeeOption: LoadingValue<Fee>]) -> [FeeRowViewModel] {
        let formattedFeeValues: [FeeOption: LoadingValue<String>] = feeValues.mapValues { fee in
            switch fee {
            case .loading:
                return .loading
            case .loaded(let value):
                let formattedValue = self.feeFormatter.format(
                    fee: value.amount.value,
                    currencySymbol: walletInfo.feeCurrencySymbol,
                    currencyId: walletInfo.feeCurrencyId,
                    isFeeApproximate: walletInfo.isFeeApproximate
                )
                return .loaded(formattedValue)
            case .failedToLoad(let error):
                return .failedToLoad(error: error)
            }
        }

        return feeOptions.map { option in
            let value = formattedFeeValues[option] ?? .loading

            return FeeRowViewModel(
                option: option,
                subtitle: value,
                isSelected: .init(root: self, default: false, get: { root in
                    root.selectedFeeOption == option
                }, set: { root, newValue in
                    if newValue {
                        self.selectFeeOption(option)
                    }
                })
            )
        }
    }

    private func selectFeeOption(_ feeOption: FeeOption) {
        selectedFeeOption = feeOption
        input.didSelectFeeOption(feeOption)
        showCustomFeeFields = feeOption == .custom
    }
}
