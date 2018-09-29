//
//  TangemTests.swift
//  TangemTests
//
//  Created by Gennady Berezovsky on 29.09.18.
//  Copyright © 2018 Smart Cash AG. All rights reserved.
//

import XCTest
import CommonCrypto

class TangemTests: XCTestCase {

    func testCardImage() {
        
        var card = Card()
        card.batchId = 0x0008
        
        card.cardID = "AE01 0000 0000 0000"
        XCTAssertEqual(card.imageName, "card-btc001")
        
        card.cardID = "AE01 0000 0000 5000"
        XCTAssertEqual(card.imageName, "card-btc005")
    }

}
