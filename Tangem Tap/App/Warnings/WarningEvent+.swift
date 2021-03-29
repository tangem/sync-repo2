//
//  WarningEvent+.swift
//  Tangem Tap
//
//  Created by Andrew Son on 28/12/20.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation

extension WarningEvent {
    var warning: TapWarning {
        switch self {
        case .numberOfSignedHashesIncorrect:
            return WarningsList.numberOfSignedHashesIncorrect
        case .rateApp:
            return WarningsList.rateApp
        case .failedToValidateCard:
            return WarningsList.failedToVerifyCard
        }
    }
}
