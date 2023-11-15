//
//  SendSummaryViewModel.swift
//  Tangem
//
//  Created by Andrey Chukavin on 30.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

protocol SendSummaryViewModelInput: AnyObject {
    var amountTextBinding: Binding<String> { get }
    var destinationTextBinding: Binding<String> { get }
    var feeText: String { get }

    func send()
}

class SendSummaryViewModel {
    let amountText: String
    let destinationText: String
    let feeText: String

    weak var router: SendSummaryRoutable?

    private weak var input: SendSummaryViewModelInput?

    init(input: SendSummaryViewModelInput) {
        amountText = input.amountTextBinding.wrappedValue
        destinationText = input.destinationTextBinding.wrappedValue
        feeText = input.feeText

        self.input = input
    }

    func didTapSummary(for step: SendStep) {
        router?.openStep(step)
    }

    func send() {
        input?.send()
    }
}
