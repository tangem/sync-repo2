//
//  StakeView.swift
//  Tangem
//
//  Created by Sergey Balashov on 22.05.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import SwiftUI

struct StakeView: View {
    @ObservedObject private var viewModel: StakeViewModel

    init(viewModel: StakeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Text("Hello, World!")
        }
    }
}

struct StakeView_Preview: PreviewProvider {
    static let viewModel = StakeViewModel(coordinator: StakeCoordinator())

    static var previews: some View {
        StakeView(viewModel: viewModel)
    }
}
