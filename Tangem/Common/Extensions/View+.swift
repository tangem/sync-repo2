//
//  VIew+.swift
//  Tangem
//
//  Created by Alexander Osokin on 02.11.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
	func toAnyView() -> AnyView {
		AnyView(self)
	}
    
    @ViewBuilder func tintCompat(_ color: Color) -> some View {
        if #available(iOS 15.0, *) {
            self.tint(color)
        } else {
            self
        }
    }
    
    @ViewBuilder func toggleStyleCompat(_ color: Color) -> some View {
        if #available(iOS 15.0, *) {
            self.tint(color)
        } else if #available(iOS 14.0, *) {
            self.toggleStyle(SwitchToggleStyle(tint: color))
        } else {
            self
        }
    }
    
    @ViewBuilder func ignoresKeyboard() -> some View {
        if #available(iOS 14.0, *) {
            self.ignoresSafeArea(.keyboard)
        } else {
            self
        }
    }
    
    @ViewBuilder func ignoresBottomArea() -> some View {
        if #available(iOS 14.0, *) {
            self.ignoresSafeArea(.container, edges: .bottom)
        } else {
            self.edgesIgnoringSafeArea(.bottom)
        }
    }
}
