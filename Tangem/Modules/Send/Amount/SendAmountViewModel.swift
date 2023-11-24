//
//  SendAmountViewModel.swift
//  Tangem
//
//  Created by Andrey Chukavin on 30.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import BlockchainSdk

protocol SendAmountViewModelInput {
    var amountPublisher: AnyPublisher<Amount?, Never> { get }
    var amountError: AnyPublisher<Error?, Never> { get }

    var blockchain: Blockchain { get }
    var amountType: Amount.AmountType { get }

    func setAmount(_ amount: Amount?)
}

protocol SendAmountViewModelDelegate: AnyObject {
    func didSelectCurrencyOption(isFiat: Bool)
    func didTapMaxAmount()
}

class SendAmountViewModel: ObservableObject, Identifiable {
    let walletName: String
    let balance: String
    let tokenIconInfo: TokenIconInfo
    let cryptoCurrencyCode: String
    let fiatCurrencyCode: String
    let amountFractionDigits: Int
    
    var amount: Binding<DecimalNumberTextField.DecimalValue?> {
        .init(get: { [weak self] in
            guard let self else { return nil }
            return _amount
        }, set: { [weak self] newValue in
            guard let self else { return }
            input.setAmount(toAmount(newValue))
        })
    }

    @Published var currencyOption: CurrencyOption = .fiat
    @Published var amountAlternative: String = ""
    @Published var error: String?

    weak var delegate: SendAmountViewModelDelegate?

    private let input: SendAmountViewModelInput
    private var _amount: DecimalNumberTextField.DecimalValue? = nil
    private var bag: Set<AnyCancellable> = []

    init(input: SendAmountViewModelInput, walletInfo: SendWalletInfo) {
        self.input = input
        walletName = walletInfo.walletName
        balance = walletInfo.balance
        tokenIconInfo = walletInfo.tokenIconInfo
        amountFractionDigits = walletInfo.amountFractionDigits

        cryptoCurrencyCode = walletInfo.cryptoCurrencyCode
        fiatCurrencyCode = walletInfo.fiatCurrencyCode

        bind(from: input)
    }

    func didTapMaxAmount() {
        delegate?.didTapMaxAmount()
    }

    private func bind(from input: SendAmountViewModelInput) {
        input
            .amountError
            .map { $0?.localizedDescription }
            .assign(to: \.error, on: self, ownership: .weak)
            .store(in: &bag)

        input
            .amountPublisher
            .sink { [weak self] amount in
                self?._amount = self?.fromAmount(amount)
                self?.objectWillChange.send()
            }
            .store(in: &bag)

        $currencyOption
            .sink { [weak self] option in
                let isFiat = (option == .fiat)
                self?.delegate?.didSelectCurrencyOption(isFiat: isFiat)
            }
            .store(in: &bag)
    }

    private func fromAmount(_ amount: Amount?) -> DecimalNumberTextField.DecimalValue? {
        if let amount {
            return DecimalNumberTextField.DecimalValue.external(amount.value)
        } else {
            return nil
        }
    }

    private func toAmount(_ decimalValue: DecimalNumberTextField.DecimalValue?) -> Amount? {
        if let decimalValue {
            return Amount(with: input.blockchain, type: input.amountType, value: decimalValue.value)
        } else {
            return nil
        }
    }
}

extension SendAmountViewModel {
    enum CurrencyOption: String, CaseIterable, Identifiable {
        case crypto
        case fiat

        var id: Self { self }
    }
}
