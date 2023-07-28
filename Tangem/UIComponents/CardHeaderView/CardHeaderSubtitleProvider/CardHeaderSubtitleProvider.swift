//
//  CardHeaderSubtitleProvider.swift
//  Tangem
//
//  Created by Andrew Son on 28/07/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Combine

protocol CardHeaderSubtitleProvider: AnyObject {
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var subtitlePublisher: AnyPublisher<CardHeaderSubtitleInfo, Never> { get }

    var containsSensitiveInfo: Bool { get }
}
