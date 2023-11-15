//
//  SendModel.swift
//  Tangem
//
//  Created by Andrey Chukavin on 30.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import BlockchainSdk

class SendModel {
    var amountValid: AnyPublisher<Bool, Never> {
        amount
            .map {
                $0 != nil
            }
            .eraseToAnyPublisher()
    }

    var destinationValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(destination, destinationAdditionalFieldError)
            .map {
                $0 != nil && $1 == nil
            }
            .eraseToAnyPublisher()
    }

    var feeValid: AnyPublisher<Bool, Never> {
        .just(output: true)
    }

    // MARK: - Data

    private var amount = CurrentValueSubject<Amount?, Never>(nil)
    private var destination = CurrentValueSubject<String?, Never>(nil)
    private var destinationAdditionalField = CurrentValueSubject<String?, Never>(nil)
    private var fee = CurrentValueSubject<Fee?, Never>(nil)

    private var transaction = CurrentValueSubject<BlockchainSdk.Transaction?, Never>(nil)

    // MARK: - Raw data

    private var _amountText: String = ""
    private var _destinationText: String = ""
    private var _destinationAdditionalFieldText: String = ""
    private var _feeText: String = ""

    // MARK: - Errors (raw implementation)

    private var _amountError = CurrentValueSubject<Error?, Never>(nil)
    private var _destinationError = CurrentValueSubject<Error?, Never>(nil)
    private var _destinationAdditionalFieldError = CurrentValueSubject<Error?, Never>(nil)

    // MARK: - Private stuff

    private let walletModel: WalletModel
    private let sendType: SendType
    private var bag: Set<AnyCancellable> = []

    // MARK: - Public interface

    init(walletModel: WalletModel, sendType: SendType) {
        self.walletModel = walletModel
        self.sendType = sendType

        if let amount = sendType.predefinedAmount {
            #warning("TODO")
            _amountText = "\(amount)"
        }

        if let destination = sendType.predefinedDestination {
            _destinationText = destination
        }

        validateAmount()
        validateDestination()
        validateDestinationAdditionalField()
        bind()
    }

    func useMaxAmount() {
        setAmount("1000")
    }

    func send() {
        print("SEND")
    }

    private func bind() {
        #warning("TODO: fee retry?")
        Publishers.CombineLatest(amount, destination)
            .flatMap { [unowned self] amount, destination -> AnyPublisher<[Fee], Never> in
                guard let amount, let destination else {
                    return .just(output: [])
                }

                #warning("TODO: loading fees")
                return walletModel
                    .getFee(amount: amount, destination: destination)
                    .receive(on: DispatchQueue.main)
                    .catch { [unowned self] error in
                        #warning("TODO: handle error")
                        return Just([Fee]())
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
            .sink { [unowned self] fees in
                #warning("TODO: save fees")
                fee.send(fees.first)

                print("fetched fees:", fees)
            }
            .store(in: &bag)

        Publishers.CombineLatest4(amount, destination, destinationAdditionalField, fee)
            .map { [weak self] amount, destination, destinationAdditionalField, fee -> BlockchainSdk.Transaction? in

                guard
                    let self,
                    let amount,
                    let destination,
                    let fee
                else {
                    return nil
                }

                return try? walletModel.createTransaction(
                    amountToSend: amount,
                    fee: fee,
                    destinationAddress: destination
                )
            }
            .sink { transaction in
                self.transaction.send(transaction)
                print("TX built", transaction != nil)
            }
            .store(in: &bag)
    }

    // MARK: - Amount

    private func setAmount(_ amountText: String) {
        _amountText = amountText
        validateAmount()
    }

    private func validateAmount() {
        let amount: Amount?
        let error: Error?

        #warning("validate")
        let blockchain = walletModel.blockchainNetwork.blockchain
        let amountType = walletModel.amountType

        let value = Decimal(string: _amountText, locale: Locale.current) ?? 0
        amount = Amount(with: blockchain, type: amountType, value: value)
        error = nil

        self.amount.send(amount)
        _amountError.send(error)
    }

    // MARK: - Destination and memo

    private func setDestination(_ destinationText: String) {
        _destinationText = destinationText
        validateDestination()
    }

    private func validateDestination() {
        let destination: String?
        let error: Error?

        #warning("validate")
        destination = _destinationText
        error = nil

        self.destination.send(destination)
        _destinationError.send(error)
    }

    private func setDestinationAdditionalField(_ destinationAdditionalFieldText: String) {
        _destinationAdditionalFieldText = destinationAdditionalFieldText
        validateDestinationAdditionalField()
    }

    private func validateDestinationAdditionalField() {
        let destinationAdditionalField: String?
        let error: Error?

        #warning("validate")
        destinationAdditionalField = _destinationAdditionalFieldText
        error = nil

        self.destinationAdditionalField.send(destinationAdditionalField)
        _destinationAdditionalFieldError.send(error)
    }

    // MARK: - Fees

    private func setFee(_ feeText: String) {
        #warning("set and validate")
        _feeText = feeText
    }
}

// MARK: - Subview model inputs

extension SendModel: SendAmountViewModelInput {
    var amountTextBinding: Binding<String> { Binding(get: { self._amountText }, set: { self.setAmount($0) }) }
    var amountError: AnyPublisher<Error?, Never> { _amountError.eraseToAnyPublisher() }
}

extension SendModel: SendDestinationViewModelInput {
    var destinationTextBinding: Binding<String> { Binding(get: { self._destinationText }, set: { self.setDestination($0) }) }
    var destinationAdditionalFieldTextBinding: Binding<String> { Binding(get: { self._destinationAdditionalFieldText }, set: { self.setDestinationAdditionalField($0) }) }
    var destinationError: AnyPublisher<Error?, Never> { _destinationError.eraseToAnyPublisher() }
    var destinationAdditionalFieldError: AnyPublisher<Error?, Never> { _destinationAdditionalFieldError.eraseToAnyPublisher() }
}

extension SendModel: SendFeeViewModelInput {
    var feeTextBinding: Binding<String> { Binding(get: { self._feeText }, set: { self.setFee($0) }) }
}

extension SendModel: SendSummaryViewModelInput {
    var canEditAmount: Bool {
        sendType.predefinedAmount == nil
    }

    var canEditDestination: Bool {
        sendType.predefinedDestination == nil
    }
}
