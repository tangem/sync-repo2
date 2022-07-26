//
//  ScanTroublehootingView.swift
//  Tangem
//
//  Created by Andrew Son on 20/02/21.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import SwiftUI

struct ScanTroubleshootingView: View {

    @Binding var isPresented: Bool

    var tryAgainAction: () -> Void
    var requestSupportAction: () -> Void

    var body: some View {
        Color.clear
            .frame(width: 0.5, height: 0.5)
            .actionSheet(isPresented: $isPresented, content: {
                ActionSheet(title: Text("alert_troubleshooting_scan_card_title"),
                            message: Text("alert_troubleshooting_scan_card_message"),
                            buttons: [
                                .default(Text("alert_button_try_again"), action: {
                                    Analytics.logAmplitude(.tryAgainClicked)
                                    tryAgainAction()
                                }),
                                .default(Text("alert_button_request_support"), action: {
                                    Analytics.logAmplitude(.supportClicked)
                                    requestSupportAction()
                                }),
                                .cancel(),
                            ])
            })
    }
}
