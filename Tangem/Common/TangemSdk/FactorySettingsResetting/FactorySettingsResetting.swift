//
//  FactorySettingsResetting.swift
//  Tangem
//
//  Created by Alexander Osokin on 04.03.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk

protocol FactorySettingsResetting: AnyObject {
    func resetCard(completion: @escaping (Result<Void, TangemSdkError>) -> Void)
}
