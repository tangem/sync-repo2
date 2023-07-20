//
//  QuotesDTO.swift
//  Tangem
//
//  Created by Sergey Balashov on 13.07.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

enum QuotesDTO {
    struct Response: Decodable {
        /// Key is `coinId`
        let quotes: [String: Fields]

        struct Fields: Decodable {
            let price: String?
            let priceChange24h: String?
        }
    }

    struct Request: Encodable {
        let coinIds: [String]
        let currencyId: String
        let fields: [Fields] = [.price, .priceChange24h]

        enum Fields: String, Encodable {
            case priceChange24h
            case price
        }
    }
}
