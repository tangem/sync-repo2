//
//  AlephiumAddressTests.swift
//  TangemApp
//
//  Created by Mikhail Andreev on 3/3/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

@testable import BlockchainSdk
import TangemSdk
import Testing

struct AlephiumAddressTests {
    private let addressService: AlephiumAddressService

    init() {
        addressService = AlephiumAddressService()
    }

    @Test
    func defaultGeneration() throws {
        // given
        let publicKeyData = Data(hexString: "0x025ad4a937b43f426d1bc2de5a5061c82c5218b2d0f52c132b3ddd0d6c07c4efca")
        let expectedAddress = "1HqAa1eHkqmXuSh7ECW6jF9ygZ2CMZYe1JthwcQ7NbgUe"

        // when
        let address = try addressService.makeAddress(from: publicKeyData)

        // then
        #expect(address.value == expectedAddress)
    }

    @Test
    func addressGeneration() throws {
        // given
        let expectedAddress = "12ZGzgQEpgQCWQrD8eyNihFXBF7QPGbWzSnGQSSUES98E"

        // when
        let compressedAddress = try addressService.makeAddress(from: Keys.AddressesKeys.secpCompressedKey, type: .default)
        let decompressedAddress = try addressService.makeAddress(from: Keys.AddressesKeys.secpDecompressedKey, type: .default)

        // then
        #expect(compressedAddress.value == expectedAddress)
        #expect(compressedAddress.value == decompressedAddress.value)
        #expect(throws: (any Error).self) {
            try addressService.makeAddress(from: Keys.AddressesKeys.edKey)
        }
    }

    @Test
    func validation() throws {
        #expect(addressService.validate("12ZGzgQEpgQCWQrD8eyNihFXBF7QPGbWzSnGQSSUES98E"))
        #expect(addressService.validate("1HqAa1eHkqmXuSh7ECW6jF9ygZ2CMZYe1JthwcQ7NbgUe"))

        #expect(!addressService.validate("0x00"))
        #expect(!addressService.validate("0x0"))
        #expect(!addressService.validate("1HqAa1eHkqmXuSh7ECW6jF9ygZ2CMZYe1JthwcQ7NsKSmsak"))
        #expect(!addressService.validate("1HqAa1eHkqmXuSh7ECW6jF9ygZ2CMZYe1J"))
    }
}
