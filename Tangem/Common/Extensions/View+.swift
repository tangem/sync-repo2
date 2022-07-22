//
//  VIew+.swift
//  Tangem
//
//  Created by Alexander Osokin on 02.11.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

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

    @ViewBuilder func searchableCompat(text: Binding<String>) -> some View {
        if #available(iOS 15.0, *) {
            self.searchable(text: text, placement: .navigationBarDrawer(displayMode: .always))
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

    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder func valueChanged<T: Equatable>(value: T, onChange: @escaping (T) -> Void) -> some View {
        if #available(iOS 14.0, *) {
            self.onChange(of: value, perform: onChange)
        } else {
            self.onReceive(Just(value)) { (value) in
                onChange(value)
            }
        }
    }
}
