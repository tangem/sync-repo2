//
//  ScannedCardsRepository.swift
//  Tangem Tap
//
//  Created by Andrew Son on 13/04/21.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk



class ScannedCardsRepository {
    private(set) var cards: [String: SavedCard] = [:]
    private let storage: PersistentStorage
    private var storageKey: PersistentStorageKey { .cards }
    
    init(storage: PersistentStorage) {
        self.storage = storage
        fetch()
    }
    
    func add(_ card: Card) {
        guard let cid = card.cardId else { return }
        
        cards[cid] = .savedCard(from: card)
        save()
    }
    
    private func save() {
        try? storage.store(value: cards, for: storageKey)
    }
    
    private func fetch() {
        if let cards: [String: Card] = try? storage.value(for: storageKey) {
            self.cards = cards.compactMapValues { .savedCard(from: $0) }
            save()
            return
        }
        cards = (try? storage.value(for: storageKey)) ?? [:]
    }
}
