//
//  Fact0rnAddressTests.swift
//  TangemApp
//
//  Created by Mikhail Andreev on 3/3/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
import CryptoKit
import class WalletCore.PrivateKey
@testable import BlockchainSdk
import Testing

struct Fact0rnAddressTests {
    @Test
    func addressAnyGeneration() throws {
        let walletPublicKey = Data(hexString: "03B6D7E1FB0977A5881A3B1F64F9778B4F56CB2B9EFD6E0D03E60051EAFEBF5831")
        let expectedAddress = "fact1qg2qvzvrgukkp5gct2n8dvuxz99ddxwecmx9sey"

        let addressService = Fact0rnAddressService()
        let address = try addressService.makeAddress(from: walletPublicKey)

        #expect(address.value == expectedAddress)
    }

    @Test
    func addressValidation() throws {
        let addressService = Fact0rnAddressService()

        let validAddresses = [
            "fact1qsev9cuanvdqwuh3gnkjaqdtjkeqcw5smex9dyx",
            "fact1qpr0t2aaus7wkerkhpqw4kh6z65pf33zcawx9t0",
            "fact1qsufztqay97de6073cxjd256mu6n9ruylydpzxf",
            "fact1qg2qvzvrgukkp5gct2n8dvuxz99ddxwecmx9sey",
        ]

        for validAddress in validAddresses {
            #expect(addressService.validate(validAddress))
        }

        let unValidAddresses = [
            "",
            "1q3n6x7kgsup6zlmpmndppx6ymtk6hxh4lnttt3y",
            "fact",
        ]

        for unValidAddress in unValidAddresses {
            #expect(!addressService.validate(unValidAddress))
        }
    }

    @Test
    func makeScriptHashFromAddress() throws {
        let expectedAddress = "fact1qg2qvzvrgukkp5gct2n8dvuxz99ddxwecmx9sey"
        let expectedScriptHash = "808171256649754B402099695833B95E4507019B3E494A7DBC6F62058F09050E"

        let scriptHash = try Fact0rnAddressService.addressToScriptHash(address: expectedAddress)
        #expect(scriptHash == expectedScriptHash)
    }
}
