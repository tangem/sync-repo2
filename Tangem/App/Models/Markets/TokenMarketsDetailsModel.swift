//
//  TokenMarketsDetailsModel.swift
//  Tangem
//
//  Created by Andrew Son on 27/06/24.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation

struct TokenMarketsDetailsModel: Identifiable {
    let id: String
    let isActive: Bool
    let currentPrice: Decimal
    let shortDescription: String?
    let fullDescription: String?
    let priceChangePercentage: [String: Decimal]

    // TODO: More fields will be added in further tasks

    init(marketsDTO: MarketsDTO.Coins.Response) {
        id = marketsDTO.id
        isActive = marketsDTO.active
        currentPrice = marketsDTO.currentPrice
        shortDescription = marketsDTO.shortDescription
        fullDescription = marketsDTO.fullDescription
        priceChangePercentage = marketsDTO.priceChangePercentage
    }
}
