//
//  DeprecationServicing.swift
//  Tangem
//
//  Created by Andrew Son on 25/01/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import UIKit

protocol DeprecationServicing {
    var deprecationWarnings: [WarningEvent] { get }
    var operatingSystemDeprecated: Bool { get }
    func didDismissOSDeprecationWarning()
}

private struct DeprecationServicingKey: InjectionKey {
    static var currentValue: DeprecationServicing = DeprecationService()
}

extension InjectedValues {
    var deprecationService: DeprecationServicing {
        get { Self[DeprecationServicingKey.self] }
        set { Self[DeprecationServicingKey.self] = newValue }
    }
}
