//
//  ReferralRoutable.swift
//  Tangem
//
//  Created by Andrew Son on 02/11/22.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

protocol ReferralRoutable: AnyObject {
    func openTos(with url: URL)
    func dismiss()
}
