//
//  ExpressTokensListViewModel.swift
//  Tangem
//
//  Created by Sergey Balashov on 07.11.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Combine
import SwiftUI

struct ExpressTokensListRoutableMock: ExpressTokensListRoutable {}

final class ExpressTokensListViewModel: ObservableObject {
    // MARK: - ViewState

    // MARK: - Dependencies

    private unowned let coordinator: ExpressTokensListRoutable

    init(coordinator: ExpressTokensListRoutable) {
        self.coordinator = coordinator
    }
}
