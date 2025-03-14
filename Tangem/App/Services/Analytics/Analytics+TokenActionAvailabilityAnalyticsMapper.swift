//
//  Analytics+TokenActionAvailabilityAnalyticsMapper.swift
//  TangemApp
//
//  Created by Alexander Osokin on 03/03/2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

struct TokenActionAvailabilityAnalyticsMapper {
    func mapToParameterValue(_ status: TokenActionAvailabilityProvider.SwapActionAvailabilityStatus) -> Analytics.ParameterValue {
        switch status {
        case .available:
            return Analytics.ParameterValue.available
        case .unavailable:
            return Analytics.ParameterValue.unavailable
        case .customToken:
            return Analytics.ParameterValue.customToken
        case .blockchainUnreachable:
            return Analytics.ParameterValue.blockchainUnreachable
        case .hasOnlyCachedBalance:
            return Analytics.ParameterValue.caching
        case .cantSignLongTransactions:
            return Analytics.ParameterValue.oldPhone
        case .expressUnreachable:
            return Analytics.ParameterValue.assetsError
        case .expressLoading:
            return Analytics.ParameterValue.assetsLoading
        case .expressNotLoaded:
            return Analytics.ParameterValue.assetsNotFound
        }
    }

    func mapToParameterValue(_ status: TokenActionAvailabilityProvider.SendActionAvailabilityStatus) -> Analytics.ParameterValue {
        switch status {
        case .available:
            return Analytics.ParameterValue.available
        case .zeroWalletBalance:
            return Analytics.ParameterValue.empty
        case .cantSignLongTransactions:
            return Analytics.ParameterValue.oldPhone
        case .hasPendingTransaction:
            return Analytics.ParameterValue.pending
        case .blockchainUnreachable:
            return Analytics.ParameterValue.blockchainUnreachable
        case .oldCard:
            return Analytics.ParameterValue.oldCard
        case .hasOnlyCachedBalance:
            return Analytics.ParameterValue.caching
        }
    }

    func mapToParameterValue(_ status: TokenActionAvailabilityProvider.ReceiveActionAvailabilityStatus) -> Analytics.ParameterValue {
        switch status {
        case .available:
            return Analytics.ParameterValue.available
        case .noAddress:
            return Analytics.ParameterValue.noAddress
        case .assetRequirement:
            return Analytics.ParameterValue.assetRequirement
        }
    }

    func mapToParameterValue(_ status: TokenActionAvailabilityProvider.BuyActionAvailabilityStatus) -> Analytics.ParameterValue {
        switch status {
        case .available:
            return Analytics.ParameterValue.available
        case .expressUnreachable:
            return Analytics.ParameterValue.assetsError
        case .expressLoading:
            return Analytics.ParameterValue.assetsLoading
        case .expressNotLoaded:
            return Analytics.ParameterValue.assetsNotFound
        case .unavailable:
            return Analytics.ParameterValue.unavailable
        case .demo:
            return Analytics.ParameterValue.demo
        }
    }

    func mapToParameterValue(_ status: TokenActionAvailabilityProvider.SellActionAvailabilityStatus) -> Analytics.ParameterValue {
        switch status {
        case .available:
            return Analytics.ParameterValue.available
        case .zeroWalletBalance:
            return Analytics.ParameterValue.empty
        case .cantSignLongTransactions:
            return Analytics.ParameterValue.oldPhone
        case .hasPendingTransaction:
            return Analytics.ParameterValue.pending
        case .blockchainUnreachable:
            return Analytics.ParameterValue.blockchainUnreachable
        case .oldCard:
            return Analytics.ParameterValue.oldCard
        case .hasOnlyCachedBalance:
            return Analytics.ParameterValue.caching
        case .unavailable:
            return Analytics.ParameterValue.unavailable
        case .demo:
            return Analytics.ParameterValue.demo
        }
    }
}
