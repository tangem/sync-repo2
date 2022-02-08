//
//  ShopView.swift
//  Tangem
//
//  Created by Andrey Chukavin on 08.02.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct ShopView: View {
    @ObservedObject var viewModel: ShopViewModel
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var navigation: NavigationCoordinator
    
    var body: some View {
        Text("Hello, World!")
    }
}

struct ShopView_Previews: PreviewProvider {
    static let assembly: Assembly = .previewAssembly
    
    static var previews: some View {
        ShopView(viewModel: assembly.makeShopViewModel())
            .environmentObject(assembly.services.navigationCoordinator)
    }
}
