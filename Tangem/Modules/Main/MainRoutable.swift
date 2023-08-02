//
//  MainRoutable.swift
//  Tangem
//
//  Created by Andrew Son on 28/07/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

protocol MainRoutable: AnyObject {
    func openDetails(for cardModel: CardViewModel)
    func close(newScan: Bool)
}
