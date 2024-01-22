//
//  RateAppRoutabe.swift
//  Tangem
//
//  Created by Andrey Fedorov on 22.01.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation

protocol RateAppRoutabe: AnyObject {
    func openAppRateDialog(with viewModel: RateAppBottomSheetViewModel)
    func closeAppRateDialog()
    func openFeedbackMail(with dataCollector: EmailDataCollector, emailType: EmailType, recipient: String)
    func openAppStoreReview()
}
