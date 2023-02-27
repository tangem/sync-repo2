//
//  SprinklrSupportChatViewModel.swift
//  Tangem
//
//  Created by Sergey Balashov on 15.02.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Combine
import SwiftUI

final class SprinklrSupportChatViewModel: ObservableObject {
    // MARK: - ViewState

    // MARK: - Dependencies

    private unowned let coordinator: SprinklrSupportChatRoutable

    init(
        coordinator: SprinklrSupportChatRoutable
    ) {
        self.coordinator = coordinator
    }
}
