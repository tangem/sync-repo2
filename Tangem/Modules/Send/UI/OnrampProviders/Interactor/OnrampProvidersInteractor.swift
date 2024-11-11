//
//  OnrampProvidersInteractor.swift
//  TangemApp
//
//  Created by Sergey Balashov on 31.10.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Combine
import TangemExpress

protocol OnrampProvidersInteractor {
    var paymentMethodPublisher: AnyPublisher<OnrampPaymentMethod, Never> { get }

    var selectedProviderPublisher: AnyPublisher<LoadingValue<OnrampProvider>, Never> { get }
    var providesPublisher: AnyPublisher<[OnrampProvider], Never> { get }

    func update(selectedProvider: OnrampProvider)
}

class CommonOnrampProvidersInteractor {
    private weak var input: OnrampProvidersInput?
    private weak var output: OnrampProvidersOutput?
    private weak var paymentMethodsInput: OnrampPaymentMethodsInput?

    init(
        input: OnrampProvidersInput,
        output: OnrampProvidersOutput,
        paymentMethodsInput: OnrampPaymentMethodsInput
    ) {
        self.input = input
        self.output = output
        self.paymentMethodsInput = paymentMethodsInput
    }
}

// MARK: - OnrampProvidersInteractor

extension CommonOnrampProvidersInteractor: OnrampProvidersInteractor {
    var paymentMethodPublisher: AnyPublisher<OnrampPaymentMethod, Never> {
        guard let input = paymentMethodsInput else {
            assertionFailure("OnrampProvidersInput not found")
            return Empty().eraseToAnyPublisher()
        }

        return input
            .selectedOnrampPaymentMethodPublisher
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    var selectedProviderPublisher: AnyPublisher<LoadingValue<OnrampProvider>, Never> {
        guard let input else {
            assertionFailure("OnrampProvidersInput not found")
            return Empty().eraseToAnyPublisher()
        }

        return input
            .selectedOnrampProviderPublisher
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    var providesPublisher: AnyPublisher<[OnrampProvider], Never> {
        guard let input else {
            assertionFailure("OnrampAmountInput not found")
            return Empty().eraseToAnyPublisher()
        }

        return input.onrampProvidersPublisher.eraseToAnyPublisher()
    }

    func update(selectedProvider: OnrampProvider) {
        output?.userDidSelect(provider: selectedProvider)
    }
}
