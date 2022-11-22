//
//  WelcomeRoutable.swift
//  Tangem
//
//  Created by Alexander Osokin on 14.06.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

protocol WelcomeRoutable: AnyObject {
    func openTokensList()
    func openOnboardingModal(with input: OnboardingInput)
    func openMail(with dataCollector: EmailDataCollector, recipient: String)
    func openDisclaimer(at url: URL, _ handler: @escaping (Bool) -> Void)
    func openShop()
    func openOnboarding(with input: OnboardingInput)
    func openMain(with cardModel: CardViewModel)
}
