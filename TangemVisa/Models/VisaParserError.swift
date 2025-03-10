//
//  VisaParserError.swift
//  TangemVisa
//
//  Created by Andrew Son on 19/01/24.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import TangemFoundation

public enum VisaParserError: Int, TangemError {
    case addressResponseDoesntContainAddress = 1
    case addressesResponseHasWrongLength
    case noValidAddress
    case limitsResponseWrongLength
    case limitWrongLength
    case limitWrongSingleLimitItemsCount
    case limitWrongSingleLimitAmountsCount
    case notEnoughOTPData

    public var subsystemCode: Int {
        VisaSubsystem.paymentAccountResponseParser.rawValue
    }
}
