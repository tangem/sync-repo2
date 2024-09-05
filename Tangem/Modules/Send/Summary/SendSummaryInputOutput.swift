//
//  SendSummaryInputOutput.swift
//  Tangem
//
//  Created by Sergey Balashov on 05.07.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation
import Combine

protocol SendSummaryInput: AnyObject {
    var isReadyToSendPublisher: AnyPublisher<Bool, Never> { get }
    var summaryTransactionDataPublisher: AnyPublisher<SendSummaryTransactionData?, Never> { get }
}

protocol SendSummaryOutput: AnyObject {}

enum SendSummaryTransactionData {
    case send(amount: Decimal, fee: Decimal)
    case staking(amount: SendAmount, fee: Decimal, apr: Decimal)
}
