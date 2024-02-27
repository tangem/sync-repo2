//
//  SendAmountViewModelInputMock.swift
//  Tangem
//
//  Created by Andrey Chukavin on 01.11.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI
import Combine
import BlockchainSdk

class SendAmountViewModelInputMock: SendAmountViewModelInput {
    var amountValue: Amount? { nil }
    var amountError: AnyPublisher<Error?, Never> {
        Just(nil).eraseToAnyPublisher()
    }

    func didChangeFeeInclusion(_ isFeeIncluded: Bool) {}
}
