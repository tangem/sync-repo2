//
//  IconView.swift
//  Tangem
//
//  Created by Sergey Balashov on 22.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI
import Kingfisher

struct IconView: View {
    private let url: URL?
    private let name: String
    private let size: CGSize

    init(url: URL?, name: String, size: CGSize = CGSize(width: 36, height: 36)) {
        self.url = url
        self.name = name
        self.size = size
    }

    var body: some View {
        if #available(iOS 15.0, *) {
            cachedAsyncImage
        } else {
            kfImage
        }
    }

    @available(iOS 15.0, *)
    var cachedAsyncImage: some View {
        CachedAsyncImage(url: url, scale: UIScreen.main.scale) { phase in
            switch phase {
            case .empty:
                placeholder
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(size: size)
                    .cornerRadiusContinuous(5)
            case .failure(let error):
                Colors.Icon.informative
                    .frame(size: size)
                    .cornerRadiusContinuous(5)
                    .onAppear {
                        AppLog.shared.debug("Load image error \(error.localizedDescription)")
                    }
            @unknown default:
                EmptyView()
            }
        }
    }

    var kfImage: some View {
        KFImage(url)
            .cancelOnDisappear(true)
            .setProcessor(DownsamplingImageProcessor(size: size))
            .placeholder { placeholder }
            .fade(duration: 0.3)
            .cacheOriginalImage()
            .scaleFactor(UIScreen.main.scale)
            .resizable()
            .scaledToFit()
            .frame(size: size)
            .cornerRadiusContinuous(5)
    }

    private var placeholder: some View {
        SkeletonView()
            .frame(size: size)
            .cornerRadius(size.height / 2)
    }
}
