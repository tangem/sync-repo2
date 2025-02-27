//
//  CardActivationOrderProviderBuilder.swift
//  TangemVisa
//
//  Created by Andrew Son on 04/02/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

struct CardActivationOrderProviderBuilder {
    private let isMockedAPIEnabled: Bool

    init(isMockedAPIEnabled: Bool) {
        self.isMockedAPIEnabled = isMockedAPIEnabled
    }

    func build(
        urlSessionConfiguration: URLSessionConfiguration,
        tokensHandler: VisaAuthorizationTokensHandler,
        cardActivationStatusService: VisaCardActivationStatusService?
    ) -> CardActivationOrderProvider {
        if isMockedAPIEnabled {
            return CardActivationTaskOrderProviderMock()
        }

        let cardActivationStatusService = cardActivationStatusService ?? VisaCardActivationStatusServiceBuilder(
            isMockedAPIEnabled: isMockedAPIEnabled).build(urlSessionConfiguration: urlSessionConfiguration)

        let productActivationService = CommonProductActivationService(
            authorizationTokensHandler: tokensHandler,
            apiService: .init(
                provider: MoyaProviderBuilder().buildProvider(configuration: urlSessionConfiguration),
                decoder: JSONDecoder()
            )
        )

        return CommonCardActivationOrderProvider(
            accessTokenProvider: tokensHandler,
            activationStatusService: cardActivationStatusService,
            productActivationService: productActivationService
        )
    }
}
