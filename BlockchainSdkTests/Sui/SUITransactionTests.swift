//
// SUITest.swift
// BlockchainSdkTests
//
// Created by Sergei Iakovlev on 03.09.2024
// Copyright © 2024 Tangem AG. All rights reserved.
//

import WalletCore
@testable import BlockchainSdk
import Testing

struct SUITransactionTest {
    var coinDecimalValue = Decimal(1_000_000_000)
    var inputs: [SuiCoinObject] = [
        SuiCoinObject(coinType: "0x2::sui::SUI", coinObjectId: "0x0ddca1f7dfebcc35b8a1238660dacd5062111614c118ccd6cd1ba0958ba5cff3", version: 333786167, digest: "127TTe3fyhURjzUxAhByCVxb5TkQbkBiLmk8xnpiuy2b", balance: 96322212),
    ]

    @Test
    func buildTransaction() throws {
        let expectedMessageHash = Data(hex: "ab83d3b957d8cc3d50cb9c5c874bce11b8107e1be914afafad82902bccf9bcdb")
        let expectedUnsigendTx = "AAACAAjoAwAAAAAAAAAgVOgNdteQwnf1pE886S9T0m9YlIkr85Xe5jdZiIdr5rICAgABAQAAAQEDAAAAAAEBAFToDXbXkMJ39aRPPOkvU9JvWJSJK/OV3uY3WYiHa+ayAQ3cofff68w1uKEjhmDazVBiERYUwRjM1s0boJWLpc/zNyzlEwAAAAAgAEjhf33FW2O7fAi2fBNdv3GP4r5VBU6W6S/8bpQJOAxU6A1215DCd/WkTzzpL1PSb1iUiSvzld7mN1mIh2vmsu4CAAAAAAAAwMYtAAAAAAAA"
        let expectedSignatureData = Data(hex: "f40d654e0fdd36d6270c25ca0691d941bc41a2f6d83ac8e8512b12fedd67b2dcb998f2378098af090532185e043f87b2d5719b7edd60cdfecb23d1b538d8ce0d")
        let expectedSignature = "APQNZU4P3TbWJwwlygaR2UG8QaL22DrI6FErEv7dZ7LcuZjyN4CYrwkFMhheBD+HstVxm37dYM3+yyPRtTjYzg2F69FEH+T5VPvl3GB3vwCOEZpeJpKXxvcIPQAdKsh2/g=="

        let privateKeyRaw = Data(hex: "7e6682f7bf479ef0f627823cffd4e1a940a7af33e5fb39d9e0f631d2ecc5daff")
        let privateKey = WalletCore.PrivateKey(data: privateKeyRaw)!
        let publicKey = privateKey.getPublicKeyEd25519()

        let walletPublicKey = Wallet.PublicKey(seedKey: publicKey.data, derivationType: nil)
        let address = try! SuiAddressService().makeAddress(for: walletPublicKey, with: .default).value

        let amount = Amount(with: .sui(curve: .ed25519_slip0010, testnet: false), value: Decimal(1000) / coinDecimalValue)
        let fee = Fee(.init(with: .sui(curve: .ed25519_slip0010, testnet: false), value: 0), parameters: SuiFeeParameters(gasPrice: 750, gasBudget: 3000000))

        let transaction = Transaction(
            amount: amount,
            fee: fee,
            sourceAddress: address,
            destinationAddress: address,
            changeAddress: ""
        )

        let txBuilder = try SuiTransactionBuilder(walletAddress: address, publicKey: walletPublicKey, decimalValue: coinDecimalValue)
        txBuilder.update(coins: inputs)

        let signature = expectedSignatureData
        let hash = try txBuilder.buildForSign(transaction: transaction)
        let output = try txBuilder.buildForSend(transaction: transaction, signature: signature)

        #expect(hash == expectedMessageHash)
        #expect(output.txBytes == expectedUnsigendTx)
        #expect(output.signature == expectedSignature)
    }

    @Test
    func transactionSize() throws {
        let sizeTester = TransactionSizeTesterUtility()

        let walletPublicKey = Wallet.PublicKey(seedKey: .init(hex: "85ebd1441fe4f954fbe5dc6077bf008e119a5e269297c6f7083d001d2ac876fe"), derivationType: nil)
        let address = try! SuiAddressService().makeAddress(for: walletPublicKey, with: .default).value

        let amount = Amount(with: .sui(curve: .ed25519_slip0010, testnet: false), value: Decimal(1000) / coinDecimalValue)
        let fee = Fee(.init(with: .sui(curve: .ed25519_slip0010, testnet: false), value: 0), parameters: SuiFeeParameters(gasPrice: 750, gasBudget: 3000000))

        let transaction = Transaction(
            amount: amount,
            fee: fee,
            sourceAddress: address,
            destinationAddress: address,
            changeAddress: ""
        )

        let txBuilder = try SuiTransactionBuilder(walletAddress: address, publicKey: walletPublicKey, decimalValue: coinDecimalValue)
        txBuilder.update(coins: inputs)

        let dataForSign = try txBuilder.buildForSign(transaction: transaction)
        sizeTester.testTxSize(dataForSign)
    }
}
