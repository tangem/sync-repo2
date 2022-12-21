//
//  ResetToFactoryAttentionViewModel.swift
//  Tangem
//
//  Created by Sergey Balashov on 28.07.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

class ResetToFactoryAttentionViewModel: ObservableObject {
    @Published var actionSheet: ActionSheetBinder?
    
    let navigationTitle: String
    let title: String
    let message: String

    let warningText: String?
    let buttonTitle: LocalizedStringKey
    let resetToFactoryAction: () -> Void

    init(
        navigationTitle: String,
        title: String,
        message: String,
        warningText: String? = nil,
        buttonTitle: LocalizedStringKey,
        resetToFactoryAction: @escaping () -> Void
    ) {
        self.navigationTitle = navigationTitle
        self.title = title
        self.message = message
        self.warningText = warningText
        self.buttonTitle = buttonTitle
        self.resetToFactoryAction = resetToFactoryAction
    }
    
    func mainButtonDidTap() {
        showConfirmationAlert()
    }
}

extension ResetToFactoryAttentionViewModel {
    private func showConfirmationAlert() {
        let sheet = ActionSheet(
            title: Text("card_settings_action_action_sheet_title".localized),
            buttons: [
                .destructive(Text("card_settings_action_action_sheet_reset".localized)) { [weak self] in
                    self?.resetToFactoryAction()
                },
                .cancel(Text("common_cancel"))
            ])

        self.actionSheet = ActionSheetBinder(sheet: sheet)
    }
}
