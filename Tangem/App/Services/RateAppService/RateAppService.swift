//
//  RateAppService.swift
//  Tangem
//
//  Created by Andrey Fedorov on 12.12.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

protocol RateAppService {
    func requestRateAppIfAvailable(with request: RateAppRequest)
}
