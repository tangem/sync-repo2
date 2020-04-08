//
//  PrimitiveSequence+.swift
//  BlockchainSdk
//
//  Created by Alexander Osokin on 08.04.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import SwiftyJSON

extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    /// Maps data received from the signal into a SwiftyJSON object. If the conversion fails, the signal errors.
    public func mapSwiftyJSON(failsOnEmptyData: Bool = true) -> Single<JSON> {
        return mapJSON(failsOnEmptyData: failsOnEmptyData)
            .map { return JSON($0) }
    }
}

