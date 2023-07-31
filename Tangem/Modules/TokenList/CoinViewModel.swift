//
//  LegacyCoinViewModel.swift
//  Tangem
//
//  Created by Alexander Osokin on 18.03.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

class CoinViewModel: Identifiable, ObservableObject {
    let id: UUID = .init()
    let imageURL: URL?
    let name: String
    let symbol: String

    init(imageURL: URL?, name: String, symbol: String) {
        self.imageURL = imageURL
        self.name = name
        self.symbol = symbol
    }

    init(with model: CoinModel) {
        name = model.name
        symbol = model.symbol
        imageURL = model.imageURL
    }
}

extension CoinViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CoinViewModel, rhs: CoinViewModel) -> Bool {
        lhs.id == rhs.id
    }
}
