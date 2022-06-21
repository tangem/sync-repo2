//
//  SceneCoordinatorView.swift
//  Tangem
//
//  Created by Alexander Osokin on 20.06.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

struct SceneCoordinatorView: CoordinatorView {
    @ObservedObject var coordinator: SceneCoordinator
    
    var body: some View {
        AppCoordinatorView(coordinator: coordinator.appCoordinator)
    }
}
