//
//  CardSettingsView.swift
//  Tangem
//
//  Created by Sergey Balashov on 29.06.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct CardSettingsView: View {
    @ObservedObject var viewModel: CardSettingsViewModel

    var firstSectionFooterTitle: String {
        if viewModel.isChangeAccessCodeVisible {
            return "card_settings_change_access_code_footer".localized
        } else {
            return "card_settings_security_mode_footer".localized
        }
    }

    var body: some View {
        List {
            cardInfoSection

            securityModeSection
        }
        .listStyle(DefaultListStyle())
        .alert(item: $viewModel.alert) { $0.alert }
        .background(Colors.Background.secondary.edgesIgnoringSafeArea(.all))
        .navigationBarTitle("card_settings_title", displayMode: .inline)
    }

    private var cardInfoSection: some View {
        Section(content: {
            DefaultRowView(
                title: "details_row_title_cid".localized,
                details: viewModel.cardId
            )

            DefaultRowView(
                title: "details_row_title_issuer".localized,
                details: viewModel.cardIssuer
            )

            if let cardSignedHashes = viewModel.cardSignedHashes {
                DefaultRowView(
                    title: "details_row_title_signed_hashes".localized,
                    details: "details_row_subtitle_signed_hashes_format".localized(cardSignedHashes)
                )
            }
        })
    }

    private var securityModeSection: some View {
        Section(content: {
            DefaultRowView(
                title: "card_settings_security_mode".localized,
                details: viewModel.securityModeTitle,
                action: viewModel.hasSingleSecurityMode ? nil : viewModel.openSecurityMode
            )

            if viewModel.isChangeAccessCodeVisible {
                DefaultRowView(
                    title: "card_settings_change_access_code".localized,
                    action: viewModel.openChangeAccessCodeWarningView
                )
            }
        }, footer: {
            DefaultFooterView(title: firstSectionFooterTitle)
        })
    }
}
