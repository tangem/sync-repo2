//
//  BitcoinTransactionBuilder.swift
//  BlockchainSdk
//
//  Created by Alexander Osokin on 10.12.2019.
//  Copyright © 2019 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
import BitcoinCore

class BitcoinTransactionBuilder {
    let bitcoinManager: BitcoinManager
    let unspentOutputManager: UnspentOutputManager

    private(set) var changeScript: Data?
    private let walletScripts: [BitcoinScript]

    init(bitcoinManager: BitcoinManager, unspentOutputManager: UnspentOutputManager, addresses: [Address]) {
        self.bitcoinManager = bitcoinManager
        self.unspentOutputManager = unspentOutputManager

        let scriptAddresses = addresses.compactMap { $0 as? BitcoinScriptAddress }
        let scripts = scriptAddresses.map { $0.script }
        let defaultScriptData = scriptAddresses
            .first(where: { $0.type == .default })
            .map { $0.script.data }

        walletScripts = scripts
        changeScript = defaultScriptData?.sha256()
    }

    func fillBitcoinManager() {
        let utxos = unspentOutputManager.allOutputs().map {
            UtxoDTO(
                hash: Data($0.output.hash.reversed()),
                index: $0.output.index,
                value: Int($0.output.amount),
                script: $0.script
            )
        }

        let spendingScripts: [Script] = walletScripts.compactMap { script in
            let chunks = script.chunks.enumerated().map { index, chunk in
                Chunk(scriptData: script.data, index: index, payloadRange: chunk.range)
            }
            return Script(with: script.data, chunks: chunks)
        }

        bitcoinManager.fillBlockchainData(unspentOutputs: utxos, spendingScripts: spendingScripts)
    }

    func buildForSign(transaction: Transaction, sequence: Int?, sortType: TransactionDataSortType = .bip69) -> [Data]? {
        do {
            guard let parameters = transaction.fee.parameters as? BitcoinFeeParameters else { return nil }

            let hashes = try bitcoinManager.buildForSign(
                target: transaction.destinationAddress,
                amount: transaction.amount.value,
                feeRate: parameters.rate,
                sortType: sortType,
                changeScript: changeScript,
                sequence: sequence
            )
            return hashes
        } catch {
            BSDKLogger.error(error: error)
            return nil
        }
    }

    func buildForSend(transaction: Transaction, signatures: [Data], sequence: Int?, sortType: TransactionDataSortType = .bip69) -> Data? {
        guard let signatures = convertToDER(signatures),
              let parameters = transaction.fee.parameters as? BitcoinFeeParameters else {
            return nil
        }

        do {
            return try bitcoinManager.buildForSend(
                target: transaction.destinationAddress,
                amount: transaction.amount.value,
                feeRate: parameters.rate,
                sortType: sortType,
                derSignatures: signatures,
                changeScript: changeScript,
                sequence: sequence
            )
        } catch {
            BSDKLogger.error(error: error)
            return nil
        }
    }

    private func convertToDER(_ signatures: [Data]) -> [Data]? {
        var derSigs = [Data]()

        let utils = Secp256k1Utils()
        for signature in signatures {
            guard let signDer = try? utils.serializeDer(signature) else {
                return nil
            }

            derSigs.append(signDer)
        }

        return derSigs
    }
}
