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

    @ViewBuilder
    func tintCompat(_ color: Color) -> some View {
        if #available(iOS 15.0, *) {
            self.tint(color)
        } else {
            self
        }
    }

    @ViewBuilder
    func toggleStyleCompat(_ color: Color) -> some View {
        if #available(iOS 15.0, *) {
            self.tint(color)
        } else {
            toggleStyle(SwitchToggleStyle(tint: color))
        }
    }

    @ViewBuilder
    func searchableCompat(text: Binding<String>) -> some View {
        if #available(iOS 15.0, *) {
            self.searchable(text: text, placement: .navigationBarDrawer(displayMode: .always))
        } else {
            self
        }
    }

    @ViewBuilder
    func searchableCompatWithoutCorrection(text: Binding<String>) -> some View {
        if #available(iOS 15.0, *) {
            self.searchable(
                text: text,
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .keyboardType(.alphabet)
            .autocorrectionDisabled(true)
        } else {
            self
        }
    }

    @ViewBuilder
    func interactiveDismissDisabledCompat() -> some View {
        if #available(iOS 15, *) {
            self.interactiveDismissDisabled()
        } else {
            self
        }
    }

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    func style(_ font: Font, color: Color) -> some View {
        self.font(font).foregroundColor(color)
    }

    /// A way to hide a SwiftUI view without altering the structural identity.
    /// See https://developer.apple.com/tutorials/swiftui-concepts/choosing-the-right-way-to-hide-a-view for details
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0.0 : 1.0)
    }

    @available(iOS, obsoleted: 15.0, message: "Delete when the minimum deployment target reaches 15.0")
    func ios14FixedHeight(_ height: CGFloat) -> some View {
        if #unavailable(iOS 15.0) {
            return frame(height: height)
        }
        return self
    }

    /// Two separate methods exist for iOS <16.0 and >=16.0 because they must be applied at the different levels
    /// of the view hierarchy in order to work.
    ///
    /// This method must be used on the content view INSIDE `ScrollView`, otherwise it won't work.
    /// See an example below:
    /// ```
    /// struct SomeView: View {
    ///     @State private var isScrollDisabled = false
    ///
    ///     var body: some View {
    ///         ScrollView {
    ///             LazyVStack() {
    ///                 // Some scrollable content
    ///             }
    ///             .ios15AndBelowScrollDisabledCompat(isScrollDisabled)
    ///         }
    ///     }
    /// }
    /// ```
    @available(iOS, obsoleted: 16.0, message: "Replace with native 'scrollDisabled(_:)' when the minimum deployment target reaches 16.0")
    @ViewBuilder
    func ios15AndBelowScrollDisabledCompat(_ disabled: Bool) -> some View {
        if #available(iOS 16.0, *) {
            self
        } else {
            modifier(IOS15AndBelowScrollDisabledModifier(isDisabled: disabled))
        }
    }

    /// Two separate methods exist for iOS <16.0 and >=16.0 because they must be applied at the different levels
    /// of the view hierarchy in order to work.
    ///
    /// This method  must be used OUTSIDE of `ScrollView` (as well as the native `scrollDisabled(_:)`) , otherwise it won't work.
    /// See an example below:
    /// ```
    /// struct SomeView: View {
    ///     @State private var isScrollDisabled = false
    ///
    ///     var body: some View {
    ///         ScrollView {
    ///             LazyVStack() {
    ///                 // Some scrollable content
    ///             }
    ///         }
    ///         .ios16AndAboveScrollDisabledCompat(isScrollDisabled)
    ///     }
    /// }
    /// ```
    @available(iOS, obsoleted: 16.0, message: "Replace with native 'scrollDisabled(_:)' when the minimum deployment target reaches 16.0")
    @ViewBuilder
    func ios16AndAboveScrollDisabledCompat(_ disabled: Bool) -> some View {
        if #available(iOS 16.0, *) {
            scrollDisabled(disabled)
        } else {
            self
        }
    }
}
