//
//  SendViewModel.swift
//  Tangem
//
//  Created by Andrey Chukavin on 30.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Combine
import SwiftUI

final class SendViewModel: ObservableObject {
    // MARK: - ViewState

    @Published var step: SendStep

    var showBackButton: Bool {
        if case .summary = step {
            return false
        } else {
            return step.previousStep != nil
        }
    }

    var showNextButton: Bool {
        step.nextStep != nil
    }

    var title: String {
        step.name
    }

    var sendAmountInput: SendAmountInput {
        sendModel
    }
    
    var sendAmountValidator: SendAmountValidator {
        sendModel
    }

    var sendDestinationInput: SendDestinationInput {
        sendModel
    }
    
    var sendDestinationValidator: SendDestinationValidator {
        sendModel
    }

    var sendFeeInput: SendFeeInput {
        sendModel
    }

    var sendSummaryInput: SendSummaryInput {
        sendModel
    }

    // MARK: - Dependencies

    private unowned let coordinator: SendRoutable
    private let sendModel: SendModel
    private var bag: Set<AnyCancellable> = [] // remove?

    init(
        coordinator: SendRoutable
    ) {
        self.coordinator = coordinator
        sendModel = SendModel()
        step = .amount

        sendModel.$amountText
            .sink { s in
                print("!!!", s)
            }
            .store(in: &bag)

        sendModel.$amount
            .sink { amount in
                print("New amount", amount)
            }
            .store(in: &bag)

        sendModel.amountText = "100"
        sendModel.destinationText = "0x8C8D7C46219D9205f056f28fee5950aD564d7465"
        sendModel.feeText = "Fast 🐰"
    }

    func next() {
        if let nextStep = step.nextStep {
//            withAnimation() {
            step = nextStep
//            }
        }
    }

    func back() {
        if let previousStep = step.previousStep {
            withAnimation(.easeOut) {
                step = previousStep
            }
        }
    }
}

extension SendViewModel: SendSummaryRoutable {
    func openStep(step: SendStep) {
        withAnimation(.easeOut(duration: 0.3)) {
            self.step = step
        }
    }

    func send() {
        sendModel.send()
    }
}
