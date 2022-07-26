//
//  DetailsRoutable.swift
//  Tangem
//
//  Created by Alexander Osokin on 16.06.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

protocol DetailsRoutable: AnyObject {
    func openOnboardingModal(with input: OnboardingInput)
    func openMail(with dataCollector: EmailDataCollector, support: EmailSupport, emailType: EmailType)
    func openWalletConnect(with cardModel: CardViewModel)
    func openCurrencySelection(autoDismiss: Bool)
    func openDisclaimer()
    func openCardTOU(at url: URL)
    func openResetToFactory(action: @escaping (_ completion: @escaping (Result<Void, Error>) -> Void) -> Void)
    func openScanCardSettings(with cardModel: CardViewModel)
    func openAppSettings(with cardModel: CardViewModel)
    func openSupportChat()
}
