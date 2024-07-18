//
//  MarketsListOrderBottonSheetView.swift
//  Tangem
//
//  Created by skibinalexander on 03.06.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import SwiftUI

struct MarketsListOrderBottonSheetView: View {
    @ObservedObject var viewModel: MarketsListOrderBottonSheetViewModel

    var body: some View {
        VStack(spacing: .zero) {
            BottomSheetHeaderView(title: Localization.marketsSortByTitle)

            GroupedSection(viewModel.listOptionViewModel) {
                DefaultSelectableRowView(data: $0, selection: $viewModel.currentOrderType)
            }
            .settings(\.backgroundColor, Colors.Background.action)
        }
        .padding(.horizontal, 16)
    }
}
