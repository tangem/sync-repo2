//
//  Blockchain.swift
//  blockchainSdk
//
//  Created by Alexander Osokin on 04.12.2019.
//  Copyright © 2019 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk

public enum Blockchain {
    case bitcoin(testnet: Bool)
    case litecoin
    case stellar(testnet: Bool)
    case ethereum(testnet: Bool)
    case rsk(testnet: Bool)
    case bitcoinCash(testnet: Bool)
    case binance(testnet: Bool)
    case cardano
    case xrp(curve: EllipticCurve)
    case ducatus
    
    public var isTestnet: Bool {
        switch self {
        case .bitcoin(let testnet):
            return testnet
        case .litecoin, .ducatus, .cardano, .xrp:
            return false
        case .stellar(let testnet):
            return testnet
        case .ethereum(let testnet):
            return testnet
        case .rsk(let testnet):
            return testnet
        case .bitcoinCash(let testnet):
            return testnet
        case .binance(let testnet):
            return testnet
        }
    }
    
    public var decimalCount: Int {
        switch self {
        case .bitcoin, .litecoin, .bitcoinCash, .ducatus:
            return 8
        case .ethereum, .rsk:
            return 18
        case  .cardano, .xrp:
            return 6
        case .binance:
            return 8
        case .stellar:
            return 7
        }
    }
    
    public var roundingMode: NSDecimalNumber.RoundingMode {
        switch self {
        case .bitcoin, .litecoin, .ethereum, .rsk, .bitcoinCash, .binance, .ducatus:
            return .down
        case .stellar, .xrp:
            return .plain
        case .cardano:
            return .up
        }
    }
    public var currencySymbol: String {
        switch self {
        case .bitcoin:
            return "BTC"
        case .litecoin:
            return "LTC"
        case .stellar:
            return "XLM"
        case .ethereum:
            return "ETH"
        case .rsk:
            return "RBTC"
        case .bitcoinCash:
            return "BCH"
        case .binance:
            return "BNB"
        case .ducatus:
            return "DUC"
        case .cardano:
            return "ADA"
        case .xrp:
            return "XRP"
        }
    }
    
    public func makeAddress(from walletPublicKey: Data) -> String {
        switch self {
        case .bitcoin(let testnet):
            return BitcoinAddressFactory().makeAddress(from: walletPublicKey, testnet: testnet)
        case .litecoin:
            return LitecoinAddressFactory().makeAddress(from: walletPublicKey, testnet: false)
        case .stellar:
            return StellarAddressFactory().makeAddress(from: walletPublicKey)
        case .ethereum, .rsk:
            return EthereumAddressFactory().makeAddress(from: walletPublicKey)
        case .bitcoinCash:
            let compressedKey = Secp256k1Utils.convertKeyToCompressed(walletPublicKey)!
            return BitcoinCashAddressFactory().makeAddress(from: compressedKey)
        case .binance(let testnet):
            let compressedKey = Secp256k1Utils.convertKeyToCompressed(walletPublicKey)!
            return BinanceAddressFactory().makeAddress(from: compressedKey, testnet: testnet)
        case .ducatus:
            return DucatusAddressFactory().makeAddress(from: walletPublicKey, testnet: false)
        case .cardano:
            return CardanoAddressFactory().makeAddress(from: walletPublicKey)
        case .xrp(let curve):
            var key: Data
            switch curve {
            case .secp256k1:
                key = Secp256k1Utils.convertKeyToCompressed(walletPublicKey)!
            case .ed25519:
                key = [UInt8(0xED)] + walletPublicKey
            }
            return XRPAddressFactory().makeAddress(from: key)
        }
    }
    
    public func validate(address: String) -> Bool {
        switch self {
        case .bitcoin(let testnet):
            return BitcoinAddressValidator().validate(address, testnet: testnet)
        case .litecoin, .ducatus:
            return LitecoinAddressValidator().validate(address, testnet: false)
        case .stellar:
            return StellarAddressValidator().validate(address)
        case .ethereum, .rsk:
            return EthereumAddressValidator().validate(address)
        case .bitcoinCash:
            return BitcoinCashAddressValidator().validate(address)
        case .binance(let testnet):
            return BinanceAddressValidator().validate(address, testnet: testnet)
        case .cardano:
            return CardanoAddressValidator().validate(address)
        case .xrp:
            return XRPAddressValidator().validate(address)
        }
    }
    
    public static func from(blockchainName: String, curve: EllipticCurve) -> Blockchain? {
        let testnetAttribute = "/test"
        let isTestnet = blockchainName.contains(testnetAttribute)
        let cleanName = blockchainName.remove(testnetAttribute).lowercased()
        switch cleanName {
        case "btc": return .bitcoin(testnet: isTestnet)
        case "xlm", "asset", "xlm-tag": return .stellar(testnet: isTestnet)
        case "eth", "token", "nfttoken": return .ethereum(testnet: isTestnet)
        case "ltc": return .litecoin
        case "rsk", "rsktoken": return .rsk(testnet: isTestnet)
        case "bch": return .bitcoinCash(testnet: isTestnet)
        case "binance": return .binance(testnet: isTestnet)
        case "cardano": return .cardano
        case "xrp": return .xrp(curve: curve)
        case "duc": return .ducatus
        default: return nil
        }
    }
}
