//
//  ManageTokensBottomSheetMainFooterView.swift
//  Tangem
//
//  Created by Andrey Fedorov on 28.09.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct ManageTokensBottomSheetMainFooterView: View {
    var body: some View {
        VStack(spacing: 0.0) {
            FixedSpacer(height: Constants.spacerLength, length: Constants.spacerLength)

            ManageTokensBottomSheetHeaderView(searchText: .constant(""))
                .cornerRadius(24.0, corners: [.topLeft, .topRight]) // Replicates corner radius in `BottomScrollableSheet`
                .bottomScrollableSheetGrabber()
                .bottomScrollableSheetShadow()
        }
    }
}

// MARK: - Constants

private extension ManageTokensBottomSheetMainFooterView {
    enum Constants {
        static let spacerLength = 14.0
    }
}
