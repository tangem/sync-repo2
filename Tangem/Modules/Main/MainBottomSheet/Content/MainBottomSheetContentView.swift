//
//  MainBottomSheetContentView.swift
//  Tangem
//
//  Created by Andrey Fedorov on 20.09.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct MainBottomSheetContentView: View {
    @ObservedObject var viewModel: MainBottomSheetContentViewModel

    var body: some View {
        if let manageTokensViewModel = viewModel.manageTokensViewModel {
            ManageTokensView(viewModel: manageTokensViewModel)
                .onAppear { manageTokensViewModel.onAppear() }
        }
    }
}
