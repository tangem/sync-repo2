//
//  WebViewContainer.swift
//  Tangem
//
//  Created by Sergey Balashov on 15.02.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct WebViewContainer: View {
    let viewModel: WebViewContainerViewModel

    @State private var popupUrl: URL?
    @Environment(\.presentationMode) private var presentationMode
    @State private var isLoading: Bool = true

    private var webViewContent: some View {
        WebView(
            url: viewModel.url,
            popupUrl: $popupUrl,
            urlActions: viewModel.urlActions,
            isLoading: $isLoading,
            contentInset: viewModel.contentInset
        )
    }

    private var content: some View {
        ZStack {
            if viewModel.withNavigationBar {
                webViewContent
                    .navigationBarTitle(Text(viewModel.title), displayMode: .inline)
                    .background(Color.tangemBg.edgesIgnoringSafeArea(.all))
            } else {
                webViewContent
            }

            if isLoading, viewModel.addLoadingIndicator {
                ActivityIndicatorView(color: .tangemGrayDark)
            }
        }
    }

    var body: some View {
        VStack {
            if viewModel.withCloseButton {
                NavigationView {
                    content
                        .navigationBarItems(leading:
                            Button(Localization.commonClose) {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .animation(nil)
                        )
                }
            } else {
                content
            }
        }
        .sheet(item: $popupUrl) { popupUrl in
            NavigationView {
                WebView(url: popupUrl, popupUrl: .constant(nil), isLoading: .constant(false))
                    .navigationBarTitle("", displayMode: .inline)
            }
        }
    }
}
