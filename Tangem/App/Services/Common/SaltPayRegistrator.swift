//
//  SaltPayRegistrator.swift
//  Tangem
//
//  Created by Alexander Osokin on 30.09.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
import BlockchainSdk
import web3swift
import Combine

class SaltPayRegistrator {
    @Published public private(set) var state: State = .needPin
    @Published public private(set) var error: Error? = nil
    @Published public private(set) var isBusy: Bool = false

    @Injected(\.tangemSdkProvider) private var tangemSdkProvider: TangemSdkProviding

    private let repo: SaltPayRepo = .init()
    private let api: SaltPayApi = .init()
    private let gnosis: GnosisRegistrator
    private let cardId: String
    private var bag: Set<AnyCancellable> = .init()
    private var pin: String? = nil
    private var registrationTask: RegistrationTask? = nil
    private var accessCode: String? = nil

    private let approvalValue: Decimal = 1 // TODO: TBD
    private let spendLimitValue: Decimal = 1 // TODO: TBD

    init(cardId: String,
         walletPublicKey: Data,
         gnosis: GnosisRegistrator,
         accessCode: String?) {
        self.gnosis = gnosis
        self.accessCode = accessCode
        self.cardId = cardId
        updateState()
        update()
    }

    func setPin(_ pin: String) {
        self.pin = pin
        updateState()
    }

    func update() {
        if state == .needPin || state == .noGas {
            checkGas()
        } else {
            checkRegistration()
        }
    }

    func register() {
        isBusy = true

        api
            .requestAttestationChallenge()
            .flatMap { [weak self] attestationResponse -> AnyPublisher<RegistrationTask.Response, Error> in
                guard let self = self else { return .anyFail(error: SaltPayRegistratorError.empty) }

                let task = RegistrationTask(gnosis: self.gnosis,
                                            challenge: attestationResponse.challenge,
                                            approvalValue: self.approvalValue,
                                            spendLimitValue: self.spendLimitValue)

                self.registrationTask = task

                return self.tangemSdkProvider.sdk.startSessionPublisher(with: task,
                                                                        cardId: self.cardId,
                                                                        initialMessage: nil)
                    .eraseToAnyPublisher()
                    .eraseError()
            }
            .flatMap { [weak self] response -> AnyPublisher<RegistrationTask.RegistrationTaskResponse, Error> in
                guard let self = self else { return .anyFail(error: SaltPayRegistratorError.empty) }

                guard let pin = self.pin else {
                    return .anyFail(error: SaltPayRegistratorError.needPin)
                }

                return self.api.registerWallet(pin: pin, cardSignature: response.cardSignature, salt: response.publicKeySalt)
                    .map { [weak self] registrationResponse -> RegistrationTask.RegistrationTaskResponse in
                        self?.updateState(with: registrationResponse)
                        return response
                    }
                    .eraseToAnyPublisher()
            }
            .flatMap { [gnosis] response -> AnyPublisher<[String], Error> in
                return gnosis.sendTransactions(response.signedTransactions)
            }
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.error = error
                }

                self?.isBusy = false
            } receiveValue: { [weak self] sendedTxs in
                self?.repo.data.transactionsSended = true
                self?.updateState()
            }
            .store(in: &bag)
    }

    private func updateState(with registrationResponse: RegistrationResponse? = nil) {
        var newState: State = state

        if repo.data.kycFinished {
            newState = .finished
        } else if repo.data.transactionsSended {
            newState = .kycStart
        } else if self.pin != nil {
            newState = .registration
        }

        if let response = registrationResponse {
            if !response.pin {
                newState = .needPin
            } else if !response.registration {
                newState = .registration
            } else if response.kyc == .none {
                newState = .kycStart
            } else if response.kyc == .waiting {
                newState = .kycWaiting
            } else {
                newState = .finished
            }
        }

        if newState != state {
            self.state = newState
        }
    }

    private func checkGas() {
        gnosis.checkHasGas()
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.error = error
                }
            }, receiveValue: { [weak self] hasGas in
                if hasGas {
                    self?.checkRegistration()
                } else  {
                    self?.state = .noGas
                }
            })
            .store(in: &bag)
    }

    private func checkRegistration() {
        api.checkRegistration()
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }

                if response.kyc == .success {
                    self.repo.data.kycFinished = true
                }

                self.updateState(with: response)
            }
            .store(in: &bag)
    }
}

extension SaltPayRegistrator {
    enum State: Equatable {
        case needPin
        case noGas

        case registration

        case kycStart
        case kycWaiting
        case finished
    }
}

enum SaltPayRegistratorError: Error {
    case failedToMakeTxData
    case needPin
    case empty
}

// MARK: - Gnosis chain

class GnosisRegistrator {
    private let settings: GnosisRegistrator.Settings
    private let walletManager: WalletManager
    private var transactionProcessor: EthereumTransactionProcessor { walletManager as! EthereumTransactionProcessor }
    private let cardAddress: String

    init(settings: GnosisRegistrator.Settings, walletPublicKey: Data, cardPublicKey: Data, factory: WalletManagerFactory) throws {
        self.settings = settings
        self.walletManager = try factory.makeWalletManager(blockchain: settings.blockchain, walletPublicKey: walletPublicKey)
        self.cardAddress = try Blockchain.ethereum(testnet: false).makeAddresses(from: cardPublicKey, with: nil)[0].value
    }

    func checkHasGas() -> AnyPublisher<Bool, Error> {
        walletManager.updatePublisher()
            .map { wallet -> Bool in
                if let coinAmount = wallet.amounts[.coin] {
                    return !coinAmount.isZero
                } else {
                    return false
                }
            }
            .eraseToAnyPublisher()
    }

    func sendTransactions(_ transactions: [SignedEthereumTransaction]) -> AnyPublisher<[String], Error> {
        let publishers = transactions.map { transactionProcessor.send($0) }

        return Publishers.MergeMany(publishers)
            .collect()
            .eraseToAnyPublisher()
    }

    func makeSetSpendLimitTx(value: Decimal) -> AnyPublisher<CompilledEthereumTransaction, Error>  {
        do {
            let limitAmount = Amount(with: settings.token, value: value)
            let setSpedLimitData = try makeTxData(sig: Signatures.setSpendLimit, address: cardAddress, amount: limitAmount)

            return transactionProcessor.getFee(to: settings.otpProcessorContractAddress, data: "0x\(setSpedLimitData.hexString)", amount: nil)
                .tryMap { [settings, walletManager, cardAddress] fees -> Transaction in
                    let params = EthereumTransactionParams(data: setSpedLimitData)
                    var transaction = try walletManager.createTransaction(amount: limitAmount,
                                                                          fee: fees[1],
                                                                          destinationAddress: settings.otpProcessorContractAddress,
                                                                          sourceAddress: cardAddress)
                    transaction.params = params

                    return transaction
                }
                .flatMap { [transactionProcessor] tx in
                    transactionProcessor.buildForSign(tx)
                }
                .eraseToAnyPublisher()
        } catch {
            return .anyFail(error: error)
        }
    }

    func makeInitOtpTx(rootOTP: Data, rootOTPCounter: Int) -> AnyPublisher<CompilledEthereumTransaction, Error>  {
        let initOTPData = Signatures.initOTP + rootOTP.prefix(16) + Data(count: 46) + rootOTPCounter.bytes2

        return transactionProcessor.getFee(to: settings.otpProcessorContractAddress, data: "0x\(initOTPData.hexString)", amount: nil)
            .tryMap { [settings, walletManager, cardAddress] fees -> Transaction in
                let params = EthereumTransactionParams(data: initOTPData)
                var transaction = try walletManager.createTransaction(amount: Amount(with: settings.blockchain, value: 0),
                                                                      fee: fees[1],
                                                                      destinationAddress: settings.otpProcessorContractAddress,
                                                                      sourceAddress: cardAddress)
                transaction.params = params

                return transaction
            }
            .flatMap { [transactionProcessor] tx in
                transactionProcessor.buildForSign(tx)
            }
            .eraseToAnyPublisher()
    }

    func makeSetWalletTx() -> AnyPublisher<CompilledEthereumTransaction, Error>  {
        do {
            let setWalletData = try makeTxData(sig: Signatures.setWallet, address: cardAddress, amount: nil)

            return transactionProcessor.getFee(to: settings.otpProcessorContractAddress, data: "0x\(setWalletData.hexString)", amount: nil)
                .tryMap { [settings, walletManager, cardAddress] fees -> Transaction in
                    let params = EthereumTransactionParams(data: setWalletData)
                    var transaction = try walletManager.createTransaction(amount: Amount(with: settings.blockchain, value: 0),
                                                                          fee: fees[1],
                                                                          destinationAddress: settings.otpProcessorContractAddress,
                                                                          sourceAddress: cardAddress)
                    transaction.params = params

                    return transaction
                }
                .flatMap { [transactionProcessor] tx in
                    transactionProcessor.buildForSign(tx)
                }
                .eraseToAnyPublisher()
        } catch {
            return .anyFail(error: error)
        }
    }

    func makeApprovalTx(value: Decimal) -> AnyPublisher<CompilledEthereumTransaction, Error>  {
        let approveAmount = Amount(with: settings.token, value: value)

        do {
            let approveData = try makeTxData(sig: Signatures.approve, address: settings.otpProcessorContractAddress, amount: approveAmount)

            return transactionProcessor.getFee(to: settings.token.contractAddress, data: "0x\(approveData.hexString)", amount: nil)
                .tryMap { [settings, walletManager] fees -> Transaction in
                    let params = EthereumTransactionParams(data: approveData)
                    var transaction = try walletManager.createTransaction(amount: approveAmount,
                                                                          fee: fees[1],
                                                                          destinationAddress: settings.otpProcessorContractAddress)
                    transaction.params = params

                    return transaction
                }
                .flatMap { [transactionProcessor] tx in
                    transactionProcessor.buildForSign(tx)
                }
                .eraseToAnyPublisher()
        } catch {
            return .anyFail(error: error)
        }
    }

    private func makeTxData(sig: Data, address: String, amount: Amount?) throws -> Data {
        let addressData = Data(hexString: address)

        guard let amount = amount else {
            return sig + addressData
        }

        guard let amountValue = Web3.Utils.parseToBigUInt("\(amount.value)", decimals: amount.decimals) else {
            throw SaltPayRegistratorError.failedToMakeTxData
        }

        var amountString = String(amountValue, radix: 16).remove("0X")

        while amountString.count < 64 {
            amountString = "0" + amountString
        }

        let amountData = Data(hex: amountString)

        return sig + addressData + amountData
    }
}

extension GnosisRegistrator {
    enum Signatures {
        static let approve: Data = "approve(address,uint256)".signedPrefix
        static let setSpendLimit: Data = "setSpendLimit(address,uint256)".signedPrefix
        static let initOTP: Data = "initOTP(bytes16,uint16)".signedPrefix // 0x0ac81ec3
        static let setWallet: Data = "setWallet(address)".signedPrefix // 0xdeaa59df
    }
}

extension GnosisRegistrator {
    enum Settings {
        case main
        case testnet

        var token: BlockchainSdk.Token {
            switch self {
            case .main:
                return .init(name: "WXDAI",
                             symbol: "WXDAI",
                             contractAddress: "0x4346186e7461cB4DF06bCFCB4cD591423022e417",
                             decimalCount: 18)
            case .testnet:
                return .init(name: "WXDAI Test",
                             symbol: "MyERC20",
                             contractAddress: "0x69cca8D8295de046C7c14019D9029Ccc77987A48",
                             decimalCount: 0)
            }
        }

        var otpProcessorContractAddress: String {
            switch self {
            case .main:
                return "0x3B4397C817A26521Df8bD01a949AFDE2251d91C2"
            case .testnet:
                return "0x710BF23486b549836509a08c184cE0188830f197"
            }
        }

        var blockchain: Blockchain {
            switch self {
            case .main:
                return Blockchain.saltPay(testnet: false)
            case .testnet:
                return Blockchain.saltPay(testnet: true)
            }
        }
    }
}

fileprivate extension String {
    var signedPrefix: Data {
        self.data(using: .utf8)!.sha3(.keccak256).prefix(4)
    }
}

// MARK: - Permanent storage

struct SaltPayRegistratorData: Codable {
    var transactionsSended: Bool = false
    var kycFinished: Bool = false
}

class SaltPayRepo {
    private let storageKey: String = "saltpay_registration_data"
    private let storage = SecureStorage()
    private var isFetching: Bool = false

    var data: SaltPayRegistratorData = .init() {
        didSet {
            try? save()
        }
    }

    init() {
        try? fetch()
    }

    func reset() {
        try? storage.delete(storageKey)
        data = .init()
    }

    private func save() throws {
        guard !isFetching else { return }

        let encoded = try JSONEncoder().encode(data)
        try storage.store(encoded, forKey: storageKey)
    }

    private func fetch() throws {
        self.isFetching = true
        defer { self.isFetching = false }

        if let savedData = try storage.get(storageKey) {
            self.data = try JSONDecoder().decode(SaltPayRegistratorData.self, from: savedData)
        }
    }
}

// MARK: - Networking

class SaltPayApi {
    func checkRegistration() -> AnyPublisher<RegistrationResponse, Error> {
        fatalError("not implemented")
    }

    func requestAttestationChallenge() -> AnyPublisher<AttestationResponse, Error> {
        fatalError("not implemented")
    }

    func registerWallet(pin: String, cardSignature: Data, salt: Data) -> AnyPublisher<RegistrationResponse, Error> {
        fatalError("not implemented")
    }
}

enum KYCStatus: String, Codable {
    case none
    case waiting
    case success
}

struct RegistrationResponse: Codable {
    let registration: Bool
    let pin: Bool
    let kyc: KYCStatus
}

struct AttestationResponse: Codable {
    let challenge: Data
}

// MARK: - Registration task

fileprivate class RegistrationTask: CardSessionRunnable {
    private weak var gnosis: GnosisRegistrator? = nil
    private var challenge: Data
    private let approvalValue: Decimal
    private let spendLimitValue: Decimal

    private var generateOTPCommand: GenerateOTPCommand? = nil
    private var attestWalletCommand: AttestWalletKeyCommand? = nil
    private var signCommand: SignHashesCommand? = nil

    private var generateOTPResponse: GenerateOTPResponse? = nil
    private var attestWalletResponse: AttestWalletKeyResponse? = nil
    private var signedTransactions: [SignedEthereumTransaction] = []

    private var bag: Set<AnyCancellable> = .init()

    init(gnosis: GnosisRegistrator,
         challenge: Data,
         approvalValue: Decimal,
         spendLimitValue: Decimal) {
        self.gnosis = gnosis
        self.challenge = challenge
        self.approvalValue = approvalValue
        self.spendLimitValue = spendLimitValue
    }

    deinit {
        print("RegistrationTask deinit")
    }

    func run(in session: CardSession, completion: @escaping CompletionResult<RegistrationTaskResponse>) {
        generateOTP(in: session, completion: completion)
    }

    private func generateOTP(in session: CardSession, completion: @escaping CompletionResult<RegistrationTaskResponse>) {
        let cmd = GenerateOTPCommand()
        self.generateOTPCommand = cmd

        cmd.run(in: session) { result in
            switch result {
            case .success(let response):
                self.generateOTPResponse = response
                self.attestWallet(in: session, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func attestWallet(in session: CardSession, completion: @escaping CompletionResult<RegistrationTaskResponse>) {
        guard let card = session.environment.card else {
            completion(.failure(.missingPreflightRead))
            return
        }

        guard let walletPublicKey = card.wallets.first?.publicKey else {
            completion(.failure(.walletNotFound))
            return
        }

        let cmd = AttestWalletKeyCommand(publicKey: walletPublicKey,
                                         challenge: self.challenge,
                                         confirmationMode: .dynamic)

        self.attestWalletCommand = cmd

        cmd.run(in: session) { result in
            switch result {
            case .success(let response):
                self.attestWalletResponse = response
                self.prepareTransactions(in: session, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func prepareTransactions(in session: CardSession, completion: @escaping CompletionResult<RegistrationTaskResponse>) {
        guard let gnosis = self.gnosis,
              let generateOTPResponse = self.generateOTPResponse else {
            completion(.failure(.unknownError))
            return
        }

        let txPublishers = [
            gnosis.makeApprovalTx(value: approvalValue),
            gnosis.makeSetWalletTx(),
            gnosis.makeInitOtpTx(rootOTP: generateOTPResponse.rootOTP, rootOTPCounter: generateOTPResponse.rootOTPCounter),
            gnosis.makeSetSpendLimitTx(value: spendLimitValue),
        ]

        Publishers
            .MergeMany(txPublishers)
            .collect()
            .sink { completionResult in
                if case let .failure(error) = completionResult {
                    completion(.failure(error.toTangemSdkError()))
                }
            } receiveValue: { compilledTransactions in
                self.signTransactions(compilledTransactions, in: session, completion: completion)
            }
            .store(in: &bag)
    }

    private func signTransactions(_ transactions: [CompilledEthereumTransaction],
                                  in session: CardSession,
                                  completion: @escaping CompletionResult<RegistrationTaskResponse>) {
        guard let walletPublicKey = session.environment.card?.wallets.first?.publicKey else {
            completion(.failure(.walletNotFound))
            return
        }

        let hashes = transactions.map { $0.hash }
        let cmd = SignHashesCommand(hashes: hashes, walletPublicKey: walletPublicKey)
        self.signCommand = cmd

        cmd.run(in: session) { result in
            switch result {
            case .success(let response):
                let signedTxs = zip(transactions, response.signatures).map { (tx, signature) in
                    SignedEthereumTransaction(compilledTransaction: tx, signature: signature)
                }

                self.signedTransactions = signedTxs
                self.complete(completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func complete(completion: @escaping CompletionResult<RegistrationTaskResponse>) {
        guard let attestWalletResponse = self.attestWalletResponse,
              !self.signedTransactions.isEmpty,
              let cardSignature = attestWalletResponse.cardSignature,
              let publicKeySalt = attestWalletResponse.publicKeySalt else {
            completion(.failure(.unknownError))
            return
        }

        let response = RegistrationTaskResponse(signedTransactions: signedTransactions,
                                                cardSignature: cardSignature,
                                                publicKeySalt: publicKeySalt)

        completion(.success(response))
    }
}

fileprivate extension RegistrationTask {
    struct RegistrationTaskResponse {
        let signedTransactions: [SignedEthereumTransaction]
        let cardSignature: Data
        let publicKeySalt: Data
    }
}

// TODO: pass accessCode
