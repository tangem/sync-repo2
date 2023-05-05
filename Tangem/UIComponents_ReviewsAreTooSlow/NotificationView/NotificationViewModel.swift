//
//  NotificationViewModel.swift
//  Tangem
//
//  Created by skibinalexander on 05.05.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

public struct NotificationViewModel: Identifiable {
    public struct Input {
        let mainIcon: ImageType
        let title: String
        let description: String?
        let moreIcon: ImageType?
    }

    public let id = UUID()

    let input: Input
    let primaryTapAction: (() -> Void)?
    let secondaryTapAction: (() -> Void)?
}
