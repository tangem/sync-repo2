//
//  VisaSubsystem.swift
//  TangemVisa
//
//  Created by Andrew Son on 10/03/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

enum VisaSubsystem: Int {
    case api = 1
    case authorizationTokensHandler
    case activation
    case accessCodeValidation
    case authorizationAPI
    case paymentology
    case paymentAccountResponseParser
    case cardAuthoriationProcessor
    case common
}
