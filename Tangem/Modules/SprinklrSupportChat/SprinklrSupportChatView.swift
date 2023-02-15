//
//  SprinklrSupportChatView.swift
//  Tangem
//
//  Created by Sergey Balashov on 15.02.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct SprinklrSupportChatView: View {
    @ObservedObject private var viewModel: SprinklrSupportChatViewModel

    init(viewModel: SprinklrSupportChatViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Text("Hello, World!")
        }
    }
}

struct SprinklrSupportChatView_Preview: PreviewProvider {
    static let viewModel = SprinklrSupportChatViewModel(coordinator: SprinklrSupportChatCoordinator())

    static var previews: some View {
        SprinklrSupportChatView(viewModel: viewModel)
    }
}
