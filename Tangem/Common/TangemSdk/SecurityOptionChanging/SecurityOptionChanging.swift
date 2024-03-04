//
//  SecurityOptionChanging.swift
//  Tangem
//
//  Created by Alexander Osokin on 29.02.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation
import Combine

protocol SecurityOptionChanging {
    var availableSecurityOptions: [SecurityModeOption] { get }
    var currentSecurityOption: SecurityModeOption { get }
    var currentSecurityOptionPublisher: AnyPublisher<SecurityModeOption, Never> { get }

    func changeSecurityOption(_ option: SecurityModeOption, completion: @escaping (Result<Void, Error>) -> Void)
}
