//
//  NetworkSelectorView.swift
//  Tangem
//
//  Created by Andrey Chukavin on 19.09.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct NetworkSelectorView: View {
    @ObservedObject private var viewModel: NetworkSelectorViewModel

    init(viewModel: NetworkSelectorViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Text("Hello, World!")
        }
    }
}

struct NetworkSelectorView_Preview: PreviewProvider {
    static let viewModel = NetworkSelectorViewModel(coordinator: NetworkSelectorCoordinator())

    static var previews: some View {
        NetworkSelectorView(viewModel: viewModel)
    }
}
