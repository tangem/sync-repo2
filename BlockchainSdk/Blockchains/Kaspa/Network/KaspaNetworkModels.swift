//
//  KaspaNetworkModels.swift
//  BlockchainSdk
//
//  Created by Andrey Chukavin on 13.03.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

enum KaspaDTO {
    enum UTXO {
        struct Response: Decodable {
            let outpoint: Outpoint
            let utxoEntry: UtxoEntry

            struct Outpoint: Decodable {
                let transactionId: String
                let index: Int
            }

            struct UtxoEntry: Decodable {
                let amount: String
                let scriptPublicKey: KaspaScriptPublicKeyResponse
                let blockDaaScore: String?
            }
        }
    }

    enum TransactionInfo {
        struct Response: Decodable {
            let transactionId: String
            let mass: String
            let blockTime: Int?
            let inputs: [Input]
            let outputs: [Output]

            /*
            let subnetwork_id: String?
            let hash: String?
            let payload: String?
            let block_hash: [String]?
            let is_accepted: Bool?
            let accepting_block_hash: String?
            let accepting_block_blue_score: Int?
            let accepting_block_time: Int?
             */

            struct Input: Decodable {
                let transactionId: String
                let previousOutpointAddress: String
                let previousOutpointAmount: UInt64

                /*
                let index: Int?
                let previousOutpointHash: String?
                let previousOutpointIndex: String?
                let previousOutpointResolved: Output?
                let signatureScript: String?
                let sigOpCount: String?
                */
            }

            struct Output: Decodable {
                let transactionId: String
                let amount: UInt64
                let scriptPublicScriptPublicKeyAddress: String

                /*
                 let index: Int?
                 let scriptPublicScriptPublicKey: String?
                 let scriptPublicScriptPublicKeyType: String?
                 let acceptingBlockHash: String?
                 */
            }
        }
    }

    enum EstimateFee {
        struct Response: Decodable {
            let priorityBucket: Fee
            let normalBuckets: [Fee]
            let lowBuckets: [Fee]

            struct Fee: Decodable, Comparable {
                let feerate: UInt64
                let estimatedSeconds: Decimal

                static func < (lhs: Fee, rhs: Fee) -> Bool {
                    lhs.feerate < rhs.feerate
                }
            }
        }
    }

    enum Mass {
        struct Response: Decodable {
        }
    }

    enum Send {
        struct Request: Encodable {
            let transaction: KaspaTransactionData
        }

        struct Response: Decodable {
            let transactionId: String
        }
    }
}

// MARK: - Address Info

struct KaspaAddressInfo {
    let balance: Decimal
    let unspentOutputs: [ScriptUnspentOutput]
    let confirmedTransactionHashes: [String]
}

// MARK: - Balance

struct KaspaBalanceResponse: Codable {
    let balance: Int
}

// MARK: - Blue score

struct KaspaBlueScoreResponse: Codable {
    let blueScore: UInt64
}

// MARK: - Transaction info

struct KaspaTransactionInfoResponse: Codable {
    let transactionId: String
    let isAccepted: Bool
    let acceptingBlockBlueScore: UInt64
}

// MARK: - UTXO

struct KaspaUnspentOutputResponse: Codable {
    var outpoint: KaspaOutpoint
    var utxoEntry: KaspaUtxoEntry
}

struct KaspaOutpoint: Codable {
    let transactionId: String
    let index: Int
}

struct KaspaUtxoEntry: Codable {
    let amount: String
    let scriptPublicKey: KaspaScriptPublicKeyResponse
    let blockDaaScore: String?
}

struct KaspaScriptPublicKeyResponse: Codable {
    let scriptPublicKey: String
}

// MARK: - Transaction request

struct KaspaTransactionRequest: Codable {
    let transaction: KaspaTransactionData
}

struct KaspaTransactionData: Codable {
    let version: Int
    let inputs: [KaspaInput]
    let outputs: [KaspaOutput]
    let lockTime: Int
    let subnetworkId: String

    init(
        version: Int = 0,
        inputs: [KaspaInput],
        outputs: [KaspaOutput],
        lockTime: Int = 0,
        subnetworkId: String = "0000000000000000000000000000000000000000"
    ) {
        self.version = version
        self.inputs = inputs
        self.outputs = outputs
        self.lockTime = lockTime
        self.subnetworkId = subnetworkId
    }
}

struct KaspaInput: Codable {
    let previousOutpoint: KaspaPreviousOutpoint
    let signatureScript: String
    var sequence: Int = 0
    var sigOpCount: Int = 1
}

struct KaspaPreviousOutpoint: Codable {
    let transactionId: String
    let index: Int
}

struct KaspaOutput: Codable {
    let amount: UInt64
    let scriptPublicKey: KaspaScriptPublicKey
}

struct KaspaScriptPublicKey: Codable {
    let scriptPublicKey: String
    var version: Int = 0
}

// MARK: - Transaction response

struct KaspaTransactionResponse: Codable {
    let transactionId: String
}

struct KaspaMassResponse: Decodable {
    let mass: UInt64
    let storageMass: UInt64
    let computeMass: UInt64
}

struct KaspaFeeEstimateResponse: Decodable {
    let priorityBucket: KaspaFee
    let normalBuckets: [KaspaFee]
    let lowBuckets: [KaspaFee]
}

struct KaspaFee: Decodable, Comparable {
    let feerate: UInt64
    let estimatedSeconds: Decimal

    static func < (lhs: KaspaFee, rhs: KaspaFee) -> Bool {
        lhs.feerate < rhs.feerate
    }
}
