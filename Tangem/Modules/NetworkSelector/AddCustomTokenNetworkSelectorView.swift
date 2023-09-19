//
//  AddCustomTokenNetworkSelectorView.swift
//  Tangem
//
//  Created by Andrey Chukavin on 19.09.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct AddCustomTokenNetworkSelectorView: View {
    @ObservedObject private var viewModel: AddCustomTokenNetworkSelectorViewModel

    init(viewModel: AddCustomTokenNetworkSelectorViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Text("Hello, World!")
        }
    }
}

struct AddCustomTokenNetworkSelectorView_Preview: PreviewProvider {
    static let viewModel = AddCustomTokenNetworkSelectorViewModel(coordinator: AddCustomTokenNetworkSelectorCoordinator())

    static var previews: some View {
        AddCustomTokenNetworkSelectorView(viewModel: viewModel)
    }
}
