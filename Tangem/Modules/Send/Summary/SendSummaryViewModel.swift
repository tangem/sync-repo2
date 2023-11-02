//
//  SendSummaryViewModel.swift
//  Tangem
//
//  Created by Andrey Chukavin on 30.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

protocol SendSummaryViewModelInput {
    var amountTextBinding: Binding<String> { get }
    var destinationTextBinding: Binding<String> { get }
    var feeTextBinding: Binding<String> { get }
}

class SendSummaryViewModel {
    let amountText: String
    let destinationText: String
    let feeText: String

    private let router: SendSummaryRoutable

    init(input: SendSummaryViewModelInput, router: SendSummaryRoutable) {
        amountText = input.amountTextBinding.wrappedValue
        destinationText = input.destinationTextBinding.wrappedValue
        feeText = input.feeTextBinding.wrappedValue

        self.router = router
    }

    func didTapSummary(for step: SendStep) {
        router.openStep(step)
    }

    func send() {
        router.send()
    }
}
