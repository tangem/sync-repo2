//
//  UIKitSheetModifier.swift
//  Tangem
//
//  Created by Sergey Balashov on 13.12.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct UIKitSheetModifier<Item: Identifiable, ContentView: View>: ViewModifier {
    @Binding private var item: Item?
    private var onDismiss: (() -> Void)?
    private var contentView: (Item) -> ContentView

    @StateObject private var delegate: DelegateKeeper = .init()
    @State private var controller: UIHostingController<ContentView>?

    init(item: Binding<Item?>, onDismiss: (() -> Void)? = nil, contentView: @escaping (Item) -> ContentView) {
        _item = item
        self.onDismiss = onDismiss
        self.contentView = contentView
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: item?.id) { _ in update(item: item) }
    }

    func update(item: Item?) {
        if let item = item {
            showController(item: item)
        } else {
            hideController()
        }
    }

    private func showController(item: Item) {
        let controller = controller(item: item)
        UIApplication.modalFromTop(controller, animated: true)
    }

    private func hideController() {
        controller?.dismiss(animated: true) {
            didDismiss()
        }
    }

    private func controller(item: Item) -> UIHostingController<ContentView> {
        let rootView = contentView(item)
        let controller = UIHostingController<ContentView>(rootView: rootView)

        controller.modalPresentationStyle = .automatic
        controller.overrideUserInterfaceStyle = UIApplication.topViewController?.overrideUserInterfaceStyle ?? .unspecified
        controller.transitioningDelegate = delegate

        delegate.controllerDidDissmiss = {
            didDismiss()
        }

        // Save the controller for dismiss it when it will be needed
        self.controller = controller

        return controller
    }

    private func didDismiss() {
        if item != nil {
            // Set the item to nil if the controller was closed by the user gesture
            item = nil
        }
        
        onDismiss?()
        // Just clear memory
        controller = nil
        delegate.controllerDidDissmiss = nil
    }
}

// MARK: - DelegateKeeper

extension UIKitSheetModifier {
    class DelegateKeeper: NSObject, ObservableObject, UIViewControllerTransitioningDelegate {
        var controllerDidDissmiss: (() -> Void)?

        func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            controllerDidDissmiss?()
            return nil
        }
    }
}

public extension View {
    /// In the iOS 17 we have problems with the SwiftUI sheet showing:
    /// - Toolbar in TextField disappeared randomly
    /// https://www.reddit.com/r/swift/comments/17gaa4q/keyboard_toolbar_stopped_working_in_ios_17_only
    /// - Strange memory leak when a view was showed as sheet
    /// https://developer.apple.com/forums/thread/738840
    @ViewBuilder
    func iOS17UIKitSheet<Item, Content>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View where Item: Identifiable, Content: View {
        if #available(iOS 17, *) {
            modifier(UIKitSheetModifier(item: item, onDismiss: onDismiss, contentView: content))
        } else {
            sheet(item: item, onDismiss: onDismiss, content: content)
        }
    }
}
