//
//  ExpressDestinationService.swift
//  Tangem
//
//  Created by Sergey Balashov on 10.11.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

protocol ExpressDestinationService {
    /// Has a source or destination pair
    func canBeSwapped(wallet: WalletModel) async -> Bool
    func getDestination(source: WalletModel) async throws -> WalletModel
}

enum ExpressDestinationServiceError: Error {
    case destinationNotFound
}
