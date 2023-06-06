//
//  OrganizeTokensView.swift
//  Tangem
//
//  Created by m3g0byt3 on 06.06.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct OrganizeTokensView: View {
    @ObservedObject private var viewModel: OrganizeTokensViewModel

    init(viewModel: OrganizeTokensViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView(showsIndicators: false) {}
        VStack {
            // TokenIcon
            Text("Hello, World!")
        }
    }
}

struct OrganizeTokensView_Preview: PreviewProvider {
    static let viewModel = OrganizeTokensViewModel(coordinator: OrganizeTokensCoordinator())

    static var previews: some View {
        OrganizeTokensView(viewModel: viewModel)
    }
}
