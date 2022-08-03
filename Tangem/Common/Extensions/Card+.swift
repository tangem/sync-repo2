//
//  Card+.swift
//  Tangem
//
//  Created by Andrew Son on 27/12/20.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import TangemSdk

#if !CLIP
import BlockchainSdk
#endif

extension Card {
    var canSign: Bool {
//        let isPin2Default = self.isPin2Default ?? true
//        let hasSmartSecurityDelay = settingsMask?.contains(.smartSecurityDelay) ?? false
//        let canSkipSD = hasSmartSecurityDelay && !isPin2Default

        if firmwareVersion.doubleValue < 2.28 {
            if settings.securityDelay > 15000 {
//                && !canSkipSD {
                return false
            }
        }

        return true
    }

    var canSupportSolanaTokens: Bool {
        // TODO: Old wallets. Refactor in SDK.
        let fwVersion = firmwareVersion.doubleValue
        return fwVersion >= 4.52
    }

    var isTwinCard: Bool {
        TwinCardSeries.series(for: cardId) != nil
    }

    var twinNumber: Int {
        TwinCardSeries.series(for: cardId)?.number ?? 0
    }


    var isStart2Coin: Bool {
        issuer.name.lowercased() == "start2coin"
    }

    var isTestnet: Bool {
        if batchId == "99FF" { // TODO: TBD ??
            return cardId.starts(with: batchId.reversed())
        } else {
            return false
        }
    }

    var isPermanentLegacyWallet: Bool {
        if firmwareVersion < .multiwalletAvailable {
            return wallets.first?.settings.isPermanent ?? false
        }

        return false
    }

    var walletSignedHashes: Int {
        wallets.compactMap { $0.totalSignedHashes }.reduce(0, +)
    }

    var walletCurves: [EllipticCurve] {
        wallets.compactMap { $0.curve }
    }

    #if !CLIP
    var derivationStyle: DerivationStyle {
        Card.getDerivationStyle(for: batchId, isHdWalletAllowed: settings.isHDWalletAllowed)
    }

    static func getDerivationStyle(for batchId: String, isHdWalletAllowed: Bool) -> DerivationStyle {
        guard isHdWalletAllowed else {
            return .legacy
        }

        let batchId = batchId.uppercased()

        if BatchId.isDetached(batchId) {
            return .legacy
        }

        return .new
    }

    #endif
}

// MARK: - Demo cards

extension Card {
    var isDemoCard: Bool {
        Self.demoCardIds.contains(cardId)
    }

    static var demoCardIds: [String] {
        [
            // === Not from the Google Sheet table ===

            "FB10000000000196", // Note BTC
            "FB20000000000186", // Note ETH
            "FB30000000000176", // Wallet
            "AC01000000041225",
            "AC01000000041472",
            "AB01000000046498",
            "AB01000000049608",
            "AB01000000049574",
            "AB01000000046704",
            "AB02000000051000",
            "AB02000000050911",


            // === Mvideo ===

            // Wallet
            "AC01000000045754",
            "AC01000000041662",
            "AC01000000041647",
            "AC01000000041209",
            "AC01000000042462",
            "AC01000000041100",
            "AC01000000041621",
            "AC01000000045960",
            "AC01000000041092",
            "AC01000000041217",
            "AC01000000013489",
            "AC01000000028610",
            "AC01000000028701",
            "AC01000000028578",
            "AC01000000027281",
            "AC01000000027216",
            "AC01000000028594",
            "AC01000000028602",
            "AC01000000028636",
            "AC01000000013968",
            "AC01000000027208",
            "AC01000000013471",
            "AC01000000028586",
            "AC01000000013703",
            "AC01000000028628",
            "AC01000000028693",
            "AC01000000028685",
            "AC01000000013950",
            "AC01000000013828",
            "AC01000000013497",
            "AC01000000013836",
            "AC01000000013505",
            "AC03000000046693",
            "AC03000000046685",
            "AC03000000046677",
            "AC03000000046669",
            "AC03000000046651",
            "AC03000000046644",
            "AC03000000046636",
            "AC03000000046628",
            "AC03000000046610",
            "AC03000000046602",
            "AC03000000046594",
            "AC03000000046586",
            "AC03000000046578",
            "AC03000000046560",
            "AC03000000046552",
            "AC03000000046545",
            "AC03000000046537",
            "AC03000000046529",
            "AC03000000046511",
            "AC03000000046800",
            "AC03000000046792",
            "AC03000000046784",
            "AC03000000046776",
            "AC03000000046768",
            "AC03000000046750",
            "AC03000000046743",
            "AC03000000046735",
            "AC03000000046727",
            "AC03000000046446",
            "AC03000000046438",
            "AC03000000046412",
            "AC03000000046388",
            "AC03000000046370",
            "AC03000000046354",
            "AC03000000046347",
            "AC03000000046339",
            "AC03000000046321",
            "AC03000000046172",
            "AC03000000046396",
            "AC03000000046404",
            "AC03000000046701",
            "AC03000000046420",
            "AC03000000046719",
            "AC03000000046503",
            "AC03000000046495",
            "AC03000000046487",
            "AC03000000046362",
            "AC03000000046479",
            "AC03000000046461",
            "AC03000000046453",

            // Note BTC
            "AB01000000059608",
            "AB01000000046647",
            "AB01000000046571",
            "AB01000000046746",
            "AB01000000059574",
            "AB01000000046753",
            "AB01000000046605",
            "AB01000000046761",
            "AB01000000046720",
            "AB01000000046530",
            "AB01000000016475",
            "AB01000000016483",
            "AB01000000016491",
            "AB01000000020709",
            "AB01000000020717",
            "AB01000000015550",
            "AB01000000015394",
            "AB01000000016079",
            "AB01000000016087",
            "AB01000000016095",
            "AB01000000020915",
            "AB01000000017184",
            "AB01000000020907",
            "AB01000000017192",
            "AB01000000016210",
            "AB01000000016111",
            "AB01000000016103",
            "AB01000000015766",
            "AB01000000015774",
            "AB01000000015782",
            "AB01000000022598",
            "AB01000000022580",
            "AB01000000005688",
            "AB07000000005696",
            "AB07000000005902",
            "AB07000000005910",
            "AB07000000005928",
            "AB07000000005936",
            "AB07000000005944",
            "AB07000000005993",
            "AB07000000005985",
            "AB07000000005977",
            "AB07000000005969",
            "AB07000000005951",
            "AB07000000005605",
            "AB07000000005803",
            "AB07000000005811",
            "AB07000000005829",
            "AB07000000005837",
            "AB07000000005845",
            "AB07000000005852",
            "AB07000000005860",
            "AB07000000005878",
            "AB07000000005886",
            "AB07000000005894",
            "AB07000000005704",
            "AB07000000005712",
            "AB07000000005720",
            "AB07000000005738",
            "AB07000000005746",
            "AB07000000005514",
            "AB07000000005522",
            "AB07000000005563",
            "AB07000000005571",
            "AB07000000005589",
            "AB07000000005597",
            "AB07000000005613",
            "AB07000000005621",
            "AB07000000005639",
            "AB07000000005647",
            "AB07000000005654",
            "AB07000000005662",
            "AB07000000005670",
            "AB07000000005530",
            "AB07000000005548",
            "AB07000000005555",
            "AB07000000005753",
            "AB07000000005761",
            "AB07000000005779",
            "AB07000000005787",
            "AB07000000005795",
            "AB07000000005506",

            // Note ETH
            "AB02000000051083",
            "AB02000000051059",
            "AB02000000051158",
            "AB02000000050986",
            "AB02000000051026",
            "AB02000000050960",
            "AB02000000051042",
            "AB02000000051091",
            "AB02000000051034",
            "AB02000000051133",
            "AB02000000019924",
            "AB02000000019932",
            "AB02000000022092",
            "AB02000000022282",
            "AB02000000023983",
            "AB02000000023439",
            "AB02000000020328",
            "AB02000000020310",
            "AB02000000021565",
            "AB02000000022357",
            "AB02000000023355",
            "AB02000000022324",
            "AB02000000022100",
            "AB02000000019999",
            "AB02000000020013",
            "AB02000000020005",
            "AB02000000020021",
            "AB02000000020039",
            "AB02000000020278",
            "AB02000000020252",
            "AB02000000018652",
            "AB02000000018561",
            "AB08000000009481",
            "AB08000000009473",
            "AB08000000009705",
            "AB08000000009897",
            "AB08000000009689",
            "AB08000000009671",
            "AB08000000009465",
            "AB08000000009457",
            "AB08000000009440",
            "AB08000000009432",
            "AB08000000009424",
            "AB08000000009416",
            "AB08000000009408",
            "AB08000000009390",
            "AB08000000009374",
            "AB08000000009382",
            "AB08000000009267",
            "AB08000000009275",
            "AB08000000009283",
            "AB08000000009291",
            "AB08000000009309",
            "AB08000000009317",
            "AB08000000009325",
            "AB08000000009333",
            "AB08000000009341",
            "AB08000000009358",
            "AB08000000009366",
            "AB08000000009077",
            "AB08000000009143",
            "AB08000000009168",
            "AB08000000009184",
            "AB08000000009192",
            "AB08000000009200",
            "AB08000000009226",
            "AB08000000009218",
            "AB08000000009234",
            "AB08000000009242",
            "AB08000000008574",
            "AB08000000009069",
            "AB08000000008525",
            "AB08000000009051",
            "AB08000000009135",
            "AB08000000009150",
            "AB08000000009176",
            "AB08000000009085",
            "AB08000000009093",
            "AB08000000009101",
            "AB08000000009119",
            "AB08000000009127",
            "AB08000000009259",

            // === Technopark ===

            // Wallet
            "AC01000000044120",
            "AC01000000044997",
            "AC01000000044989",
            "AC01000000043494",
            "AC01000000043486",
            "AC01000000044187",
            "AC01000000043148",
            "AC01000000044013",
            "AC01000000043973",
            "AC01000000044815",
            "AC01000000044807",
            "AC01000000043809",
            "AC01000000043833",
            "AC01000000043460",
            "AC01000000043064",
            "AC01000000044138",
            "AC01000000044500",
            "AC01000000044492",
            "AC01000000044260",
            "AC01000000044278",

            // Note BTC
            "AB01000000049864",
            "AB01000000053239",
            "AB01000000053056",
            "AB01000000054237",
            "AB01000000054245",
            "AB01000000054211",
            "AB01000000054229",
            "AB01000000053189",
            "AB01000000054195",
            "AB01000000050797",
            "AB01000000053833",
            "AB01000000052124",
            "AB01000000051605",
            "AB01000000052223",
            "AB01000000052207",
            "AB01000000052199",
            "AB01000000047785",
            "AB01000000047850",
            "AB01000000047868",
            "AB01000000048288",

            // Note ETH
            "AB02000000049715",
            "AB02000000049848",
            "AB02000000049814",
            "AB02000000049863",
            "AB02000000049871",
            "AB02000000049855",
            "AB02000000049285",
            "AB02000000049277",
            "AB02000000049558",
            "AB02000000049889",
            "AB02000000049988",
            "AB02000000049707",
            "AB02000000049699",
            "AB02000000049897",
            "AB02000000049905",
            "AB02000000049913",
            "AB02000000049251",
            "AB02000000049533",
            "AB02000000049541",
            "AB02000000049830",
        ]
    }
}
