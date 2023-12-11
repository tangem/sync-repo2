//
//  PresentationConfigurationViewModifier.swift
//  Tangem
//
//  Created by Andrey Fedorov on 11.12.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

// MARK: - Convenience extensions

@available(iOS, introduced: 15.0)
extension View {
    typealias PresentationConfiguration = (_ controller: UISheetPresentationController) -> Void

    func presentationConfiguration(
        _ configuration: @escaping PresentationConfiguration
    ) -> some View {
        modifier(PresentationConfigurationViewModifier(configuration: configuration))
    }
}

// MARK: - Private implementation

@available(iOS, introduced: 15.0)
private struct PresentationConfigurationViewModifier: ViewModifier {
    let configuration: View.PresentationConfiguration

    func body(content: Content) -> some View {
        content
            .background(SheetPresentationConfiguratorHolder(configuration: configuration))
    }
}

@available(iOS, introduced: 15.0)
private struct SheetPresentationConfiguratorHolder: UIViewControllerRepresentable {
    let configuration: View.PresentationConfiguration

    func makeUIViewController(context: Context) -> SheetPresentationConfigurator {
        let uiViewController = SheetPresentationConfigurator()
        uiViewController.configuration = configuration

        return uiViewController
    }

    func updateUIViewController(_ uiViewController: SheetPresentationConfigurator, context: Context) {
        uiViewController.configuration = configuration
        uiViewController.viewIfLoaded?.setNeedsLayout()
    }
}

@available(iOS, introduced: 15.0)
private final class SheetPresentationConfigurator: UIViewController {
    var configuration: View.PresentationConfiguration?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSheetPresentationController()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureSheetPresentationController()
    }

    private func configureSheetPresentationController() {
        guard
            let sheetPresentationController = sheetPresentationController,
            let configuration = configuration
        else {
            return
        }

        configuration(sheetPresentationController)
    }
}
