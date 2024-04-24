//
//  SendViewModel.swift
//  Tangem
//
//  Created by Andrey Chukavin on 30.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Combine
import SwiftUI
import BlockchainSdk
import AVFoundation

final class SendViewModel: ObservableObject {
    // MARK: - ViewState

    @Published var stepAnimation: SendView.StepAnimation
    @Published var step: SendStep
    @Published var showBackButton = false
    @Published var mainButtonType: SendMainButtonType
    @Published var mainButtonLoading: Bool = false
    @Published var mainButtonDisabled: Bool = false
    @Published var updatingFees = false
    @Published var currentStepInvalid: Bool = false // delete?
    @Published var canDismiss: Bool = false
    @Published var alert: AlertBinder?

    var title: String? {
        step.name(for: sendStepParameters)
    }

    var hasSubtitle: Bool {
        subtitle != nil
    }

    var subtitle: String? {
        step.description(for: sendStepParameters)
    }

    var mainButtonTitle: String {
        mainButtonType.title
    }

    var mainButtonIcon: MainButton.Icon? {
        mainButtonType.icon
    }

    var showDismissButton: Bool {
        !didReachSummaryScreen || step == .summary
    }

    var showQRCodeButton: Bool {
        switch step {
        case .destination:
            return true
        case .amount, .fee, .summary, .finish:
            return false
        }
    }

    let sendAmountViewModel: SendAmountViewModel
    let sendDestinationViewModel: SendDestinationViewModel
    let sendFeeViewModel: SendFeeViewModel
    let sendSummaryViewModel: SendSummaryViewModel

    // MARK: - Dependencies

    private let sendModel: SendModel
    private let sendType: SendType
    private let steps: [SendStep]
    private let walletModel: WalletModel
    private let userWalletModel: UserWalletModel
    private let emailDataProvider: EmailDataProvider
    private let walletInfo: SendWalletInfo
    private let notificationManager: CommonSendNotificationManager
    private let customFeeService: CustomFeeService?
    private let fiatCryptoAdapter: CommonSendFiatCryptoAdapter
    private let sendStepParameters: SendStep.Parameters
    private let keyboardVisibilityService: KeyboardVisibilityService

    private weak var coordinator: SendRoutable?

    private var bag: Set<AnyCancellable> = []
    private var feeUpdateSubscription: AnyCancellable? = nil

    private var screenIdleStartTime: Date?
    private var currentPageAnimating: Bool? = nil

    private var didReachSummaryScreen: Bool {
        get {
            didReachSummaryScreenSubject.value
        }
        set {
            didReachSummaryScreenSubject.send(newValue)
        }
    }

    private var didReachSummaryScreenSubject: CurrentValueSubject<Bool, Never> = .init(false)

    private var currentStepValid: AnyPublisher<Bool, Never> {
        let inputFieldsValid = $step
            .flatMap { [weak self] step -> AnyPublisher<Bool, Never> in
                guard let self else {
                    return .just(output: true)
                }

                switch step {
                case .amount:
                    return sendModel.amountValid
                case .destination:
                    return sendModel.destinationValid
                case .fee:
                    return sendModel.feeValid
                case .summary:
                    return sendModel.transactionCreationError
                        .map { $0 == nil }
                        .eraseToAnyPublisher()
                case .finish:
                    return .just(output: true)
                }
            }

        let hasTransactionCreationError = Publishers.CombineLatest($step, sendModel.transactionCreationError)
            .map { step, error in
                guard let validationError = error as? ValidationError else { return false }
                return validationError.step == step
            }

        return Publishers.CombineLatest(inputFieldsValid, hasTransactionCreationError)
            .map { inputFieldsValid, hasTransactionCreationError in
                inputFieldsValid && !hasTransactionCreationError
            }
            .eraseToAnyPublisher()
    }

    init(
        walletName: String,
        walletModel: WalletModel,
        userWalletModel: UserWalletModel,
        transactionSigner: TransactionSigner,
        sendType: SendType,
        emailDataProvider: EmailDataProvider,
        canUseFiatCalculation: Bool,
        coordinator: SendRoutable
    ) {
        self.coordinator = coordinator
        self.sendType = sendType
        self.walletModel = walletModel
        self.userWalletModel = userWalletModel
        self.emailDataProvider = emailDataProvider

        let addressService = SendAddressServiceFactory(walletModel: walletModel).makeService()
        #warning("TODO: pass SendModel and NotificationManager as dependencies")
        sendModel = SendModel(
            walletModel: walletModel,
            transactionSigner: transactionSigner,
            addressService: addressService,
            sendType: sendType
        )

        let steps = sendType.steps
        guard let firstStep = steps.first else {
            fatalError("No steps provided for the send type")
        }

        let didReachSummaryScreen = (firstStep == .summary)
        self.steps = steps
        step = firstStep
        didReachSummaryScreenSubject = .init(didReachSummaryScreen)
        mainButtonType = Self.mainButtonType(for: firstStep, didReachSummaryScreen: didReachSummaryScreen)
        stepAnimation = (firstStep == .summary) ? .moveAndFade : .slideForward

        let tokenIconInfo = TokenIconInfoBuilder().build(from: walletModel.tokenItem, isCustom: walletModel.isCustom)
        let cryptoIconURL: URL?
        if let tokenId = walletModel.tokenItem.id {
            cryptoIconURL = IconURLBuilder().tokenIconURL(id: tokenId)
        } else {
            cryptoIconURL = nil
        }

        let fiatIconURL = IconURLBuilder().fiatIconURL(currencyCode: AppSettings.shared.selectedCurrencyCode)

        walletInfo = SendWalletInfo(
            walletName: walletName,
            balanceValue: walletModel.balanceValue,
            balance: Localization.sendWalletBalanceFormat(walletModel.balance, walletModel.fiatBalance),
            blockchain: walletModel.blockchainNetwork.blockchain,
            currencyId: walletModel.tokenItem.currencyId,
            feeCurrencySymbol: walletModel.feeTokenItem.currencySymbol,
            feeCurrencyId: walletModel.feeTokenItem.currencyId,
            isFeeApproximate: walletModel.tokenItem.blockchain.isFeeApproximate(for: walletModel.amountType),
            tokenIconInfo: tokenIconInfo,
            cryptoIconURL: cryptoIconURL,
            cryptoCurrencyCode: walletModel.tokenItem.currencySymbol,
            fiatIconURL: fiatIconURL,
            fiatCurrencyCode: AppSettings.shared.selectedCurrencyCode,
            amountFractionDigits: walletModel.tokenItem.decimalCount,
            feeFractionDigits: walletModel.feeTokenItem.decimalCount,
            feeAmountType: walletModel.feeTokenItem.amountType,
            canUseFiatCalculation: canUseFiatCalculation
        )

        notificationManager = CommonSendNotificationManager(
            tokenItem: walletModel.tokenItem,
            feeTokenItem: walletModel.feeTokenItem,
            input: sendModel
        )

        let customFeeServiceFactory = CustomFeeServiceFactory(
            input: sendModel,
            output: sendModel,
            walletModel: walletModel
        )
        customFeeService = customFeeServiceFactory.makeService()

        fiatCryptoAdapter = CommonSendFiatCryptoAdapter(
            cryptoCurrencyId: walletInfo.currencyId,
            currencySymbol: walletInfo.cryptoCurrencyCode,
            decimals: walletInfo.amountFractionDigits
        )
        fiatCryptoAdapter.setAmount(sendType.predefinedAmount?.value)

        keyboardVisibilityService = KeyboardVisibilityService()

        sendStepParameters = SendStep.Parameters(currencyName: walletModel.tokenItem.name, walletName: walletInfo.walletName)

        sendAmountViewModel = SendAmountViewModel(input: sendModel, fiatCryptoAdapter: fiatCryptoAdapter, walletInfo: walletInfo)
        sendDestinationViewModel = SendDestinationViewModel(input: sendModel)
        sendFeeViewModel = SendFeeViewModel(input: sendModel, notificationManager: notificationManager, customFeeService: customFeeService, walletInfo: walletInfo)
        sendSummaryViewModel = SendSummaryViewModel(input: sendModel, notificationManager: notificationManager, fiatCryptoValueProvider: fiatCryptoAdapter, walletInfo: walletInfo)

        fiatCryptoAdapter.setInput(sendAmountViewModel)
        fiatCryptoAdapter.setOutput(sendModel)

        sendFeeViewModel.router = coordinator
        sendSummaryViewModel.router = self

        notificationManager.setupManager(with: self)

        updateTransactionHistoryIfNeeded()

        bind()
    }

    func onCurrentPageAppear() {
        if currentPageAnimating != nil {
            currentPageAnimating = true
        }
    }

    func onCurrentPageDisappear() {
        currentPageAnimating = false
    }

    func dismiss() {
        if step != .summary, didReachSummaryScreen {
            next()
        } else {
            coordinator?.dismiss()
        }
    }

    func next() {
        // If we try to open another page mid-animation then the appropriate onAppear of the new page will not get called
        if currentPageAnimating ?? false {
            return
        }

        switch mainButtonType {
        case .next:
            guard let nextStep = nextStep(after: step) else {
                assertionFailure("Invalid step logic -- next")
                return
            }

            logNextStepAnalytics()

            let openingSummary = (nextStep == .summary)
            let stepAnimation: SendView.StepAnimation = openingSummary ? .moveAndFade : .slideForward
            let updateFee = openingSummary && step.updateFeeOnLeave
            openStep(nextStep, stepAnimation: stepAnimation, updateFee: updateFee)
        case .continue:
            openStep(.summary, stepAnimation: .moveAndFade, updateFee: step.updateFeeOnLeave)
        case .send:
            send()
        case .close:
            coordinator?.dismiss()
        }
    }

    func back() {
        guard let previousStep = previousStep(before: step) else {
            assertionFailure("Invalid step logic -- back")
            return
        }

        openStep(previousStep, stepAnimation: .slideBackward, updateFee: false)
    }

    func scanQRCode() {
        let binding = Binding<String>(
            get: {
                ""
            },
            set: { [weak self] in
                self?.parseQRCode($0)
            }
        )

        let networkName = walletModel.blockchainNetwork.blockchain.displayName
        coordinator?.openQRScanner(with: binding, networkName: networkName)
    }

    func onSummaryAppear() {
        screenIdleStartTime = Date()
    }

    func onSummaryDisappear() {
        screenIdleStartTime = nil
    }

    private func bind() {
        Publishers.CombineLatest3($step, sendModel.amountPublisher, sendModel.isSending)
            .map { step, amount, isSending in
                if isSending {
                    return false
                }

                switch step {
                case .destination, .fee, .summary:
                    return false
                case .amount:
                    return amount == nil
                case .finish:
                    return true
                }
            }
            .assign(to: \.canDismiss, on: self, ownership: .weak)
            .store(in: &bag)

        Publishers.CombineLatest($updatingFees, sendModel.isSending)
            .map { updatingFees, isSending in
                updatingFees || isSending
            }
            .assign(to: \.mainButtonLoading, on: self, ownership: .weak)
            .store(in: &bag)

        Publishers.CombineLatest3(currentStepValid, $step, notificationManager.hasNotifications(with: .critical))
            .map { currentStepValid, step, hasCriticalNotifications in
                if !currentStepValid {
                    return true
                }

                if step == .summary, hasCriticalNotifications {
                    return true
                }

                return false
            }
            .assign(to: \.mainButtonDisabled, on: self, ownership: .weak)
            .store(in: &bag)

        $updatingFees
            .sink { [weak self] updatingFees in
                self?.sendDestinationViewModel.setUserInputDisabled(updatingFees)
                self?.sendAmountViewModel.setUserInputDisabled(updatingFees)
            }
            .store(in: &bag)

        sendModel
            .destinationPublisher
            .sink { [weak self] destination in
                guard let self else { return }

                switch destination?.source {
                case .myWallet, .recentAddress:
                    next()
                default:
                    break
                }
            }
            .store(in: &bag)

        sendModel
            .sendError
            .sink { [weak self] error in
                guard let self, let error else { return }

                Analytics.log(event: .sendErrorTransactionRejected, params: [
                    .token: walletModel.tokenItem.currencySymbol,
                ])

                if case .noAccount(_, let amount) = (error as? WalletError) {
                    let amountFormatted = Amount(
                        with: walletModel.blockchainNetwork.blockchain,
                        type: walletModel.amountType,
                        value: amount
                    ).string()
                    let title = Localization.sendNotificationInvalidReserveAmountTitle(amountFormatted)
                    let message = Localization.sendNotificationInvalidReserveAmountText

                    alert = AlertBinder(title: title, message: message)
                } else {
                    let errorCode: String
                    let reason = String(error.localizedDescription.dropTrailingPeriod)
                    if let errorCodeProviding = error as? ErrorCodeProviding {
                        errorCode = "\(errorCodeProviding.errorCode)"
                    } else {
                        errorCode = "-"
                    }

                    alert = SendError(
                        title: Localization.sendAlertTransactionFailedTitle,
                        message: Localization.sendAlertTransactionFailedText(reason, errorCode),
                        error: error,
                        openMailAction: openMail
                    )
                    .alertBinder
                }
            }
            .store(in: &bag)

        sendModel
            .transactionFinished
            .removeDuplicates()
            .sink { [weak self] transactionFinished in
                guard let self, transactionFinished else { return }

                openFinishPage()

                if walletModel.isDemo {
                    let button = Alert.Button.default(Text(Localization.commonOk)) {
                        self.coordinator?.dismiss()
                    }
                    alert = AlertBuilder.makeAlert(title: "", message: Localization.alertDemoFeatureDisabled, primaryButton: button)
                }

                Analytics.log(.sendSelectedCurrency, params: [
                    .commonType: sendAmountViewModel.useFiatCalculation ? .selectedCurrencyApp : .token,
                ])
            }
            .store(in: &bag)

        sendModel
            .destinationPublisher
            .sink { destination in
                guard let destination else { return }

                Analytics.logDestinationAddress(isAddressValid: destination.value != nil, source: destination.source)
            }
            .store(in: &bag)
    }

    private func nextStep(after step: SendStep) -> SendStep? {
        guard
            let currentStepIndex = steps.firstIndex(of: step),
            (currentStepIndex + 1) < steps.count
        else {
            return nil
        }

        return steps[currentStepIndex + 1]
    }

    private func previousStep(before step: SendStep) -> SendStep? {
        guard
            let currentStepIndex = steps.firstIndex(of: step),
            (currentStepIndex - 1) >= 0
        else {
            return nil
        }

        return steps[currentStepIndex - 1]
    }

    private func openMail(with error: Error) {
        guard let transaction = sendModel.currentTransaction() else { return }

        Analytics.log(.requestSupport, params: [.source: .transactionSourceSend])

        let emailDataCollector = SendScreenDataCollector(
            userWalletEmailData: emailDataProvider.emailData,
            walletModel: walletModel,
            fee: transaction.fee.amount,
            destination: transaction.destinationAddress,
            amount: transaction.amount,
            isFeeIncluded: sendModel.isFeeIncluded,
            lastError: error
        )
        let recipient = emailDataProvider.emailConfig?.recipient ?? EmailConfig.default.recipient
        coordinator?.openMail(with: emailDataCollector, recipient: recipient)
    }

    private func showSummaryStepAlertIfNeeded(_ step: SendStep, stepAnimation: SendView.StepAnimation, checkCustomFee: Bool) -> Bool {
        if sendModel.shouldSubtractFee {
            Analytics.log(event: .sendNoticeNotEnoughFee, params: [
                .token: walletModel.tokenItem.currencySymbol,
                .blockchain: walletModel.tokenItem.blockchain.displayName,
            ])

            alert = SendAlertBuilder.makeSubtractFeeFromMaxAmountAlert { [weak self] in
                guard let self else { return }
                sendModel.subtractFeeFromMaxAmount()
                fiatCryptoAdapter.setCrypto(sendModel.userInputAmountValue?.value)

                openStep(step, stepAnimation: stepAnimation, updateFee: false)
            }

            return true
        }

        if checkCustomFee {
            let events = notificationManager.notificationInputs.compactMap { $0.settings.event as? SendNotificationEvent }
            for event in events {
                switch event {
                case .customFeeTooLow:
                    Analytics.log(event: .sendNoticeTransactionDelaysArePossible, params: [
                        .token: walletModel.tokenItem.currencySymbol,
                    ])

                    alert = SendAlertBuilder.makeCustomFeeTooLowAlert { [weak self] in
                        self?.openStep(step, stepAnimation: stepAnimation, checkCustomFee: false, updateFee: false)
                    }

                    return true
                case .customFeeTooHigh(let orderOfMagnitude):
                    alert = SendAlertBuilder.makeCustomFeeTooHighAlert(orderOfMagnitude) { [weak self] in
                        self?.openStep(step, stepAnimation: stepAnimation, checkCustomFee: false, updateFee: false)
                    }

                    return true
                default:
                    break
                }
            }
        }

        return false
    }

    private static func mainButtonType(for step: SendStep, didReachSummaryScreen: Bool) -> SendMainButtonType {
        switch step {
        case .amount, .destination, .fee:
            if didReachSummaryScreen {
                return .continue
            } else {
                return .next
            }
        case .summary:
            return .send
        case .finish:
            return .close
        }
    }

    private func updateTransactionHistoryIfNeeded() {
        if walletModel.transactionHistoryNotLoaded {
            walletModel.updateTransactionsHistory()
                .sink()
                .store(in: &bag)
        }
    }

    private func updateFee(_ step: SendStep, stepAnimation: SendView.StepAnimation, checkCustomFee: Bool) {
        updatingFees = true

        feeUpdateSubscription = sendModel.updateFees()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.updatingFees = false

                guard case .failure = completion else { return }

                self?.alert = SendAlertBuilder.makeFeeRetryAlert {
                    self?.updateFee(step, stepAnimation: stepAnimation, checkCustomFee: checkCustomFee)
                }
            } receiveValue: { [weak self] result in
                self?.openStep(step, stepAnimation: stepAnimation, checkCustomFee: checkCustomFee, updateFee: false)
            }
    }

    private func cancelUpdatingFee() {
        feeUpdateSubscription = nil
        updatingFees = false
    }

    private func openStep(_ step: SendStep, stepAnimation: SendView.StepAnimation, checkCustomFee: Bool = true, updateFee: Bool) {
        if updateFee {
            self.updateFee(step, stepAnimation: stepAnimation, checkCustomFee: checkCustomFee)
            keyboardVisibilityService.hideKeyboard {
                // No matter how long it takes to get the fees when we try to open the step again we will check if the keyboard is open
                // If it's in the process of being hidden we will wait for it to finish
            }
            return
        }

        if keyboardVisibilityService.keyboardVisible, !step.opensKeyboardByDefault {
            keyboardVisibilityService.hideKeyboard { [weak self] in
                // Slight delay is needed, otherwise the animation of the keyboard will interfere with the page change
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self?.openStep(step, stepAnimation: stepAnimation, checkCustomFee: checkCustomFee, updateFee: updateFee)
                }
            }
            return
        }

        if case .summary = step {
            if showSummaryStepAlertIfNeeded(step, stepAnimation: stepAnimation, checkCustomFee: checkCustomFee) {
                return
            }

            sendSummaryViewModel.setupAnimations(previousStep: self.step)
        }

        // Gotta give some time to update animation variable
        self.stepAnimation = stepAnimation

        DispatchQueue.main.async {
            if step == .summary {
                self.didReachSummaryScreen = true
            }

            self.showBackButton = self.previousStep(before: step) != nil && !self.didReachSummaryScreen
            self.step = step

            self.mainButtonType = Self.mainButtonType(for: step, didReachSummaryScreen: self.didReachSummaryScreen)
        }
    }

    private func openFinishPage() {
        guard let sendFinishViewModel = SendFinishViewModel(input: sendModel, fiatCryptoValueProvider: fiatCryptoAdapter, walletInfo: walletInfo) else {
            assertionFailure("WHY?")
            return
        }

        sendFinishViewModel.router = coordinator
        openStep(.finish(model: sendFinishViewModel), stepAnimation: .moveAndFade, updateFee: false)
    }

    private func parseQRCode(_ code: String) {
        #warning("TODO: Add the necessary UI warnings")
        let parser = QRCodeParser(
            amountType: walletModel.amountType,
            blockchain: walletModel.blockchainNetwork.blockchain,
            decimalCount: walletModel.decimalCount
        )

        guard let result = parser.parse(code) else {
            return
        }

        sendModel.setDestination(SendAddress(value: result.destination, source: .qrCode))
        sendModel.setAmount(result.amount)

        if let memo = result.memo {
            sendModel.setDestinationAdditionalField(memo)
        }
    }

    private func logNextStepAnalytics() {
        switch step {
        case .fee:
            Analytics.log(event: .sendFeeSelected, params: [.feeType: selectedFeeTypeAnalyticsParameter().rawValue])
        default:
            break
        }
    }

    private func selectedFeeTypeAnalyticsParameter() -> Analytics.ParameterValue {
        if sendModel.feeOptions.count == 1 {
            return .transactionFeeFixed
        }

        switch sendModel.selectedFeeOption {
        case .slow:
            return .transactionFeeMin
        case .market:
            return .transactionFeeNormal
        case .fast:
            return .transactionFeeMax
        case .custom:
            return .transactionFeeCustom
        }
    }

    // TODO: Andrey Fedorov - Re-use fee currency & redirect logic from Token Details & Send (IOS-5710)
    private func openNetworkCurrency() {
        guard
            let networkCurrencyWalletModel = userWalletModel.walletModelsManager.walletModels.first(where: {
                $0.tokenItem == .blockchain(walletModel.tokenItem.blockchainNetwork) && $0.blockchainNetwork == walletModel.blockchainNetwork
            })
        else {
            assertionFailure("Network currency WalletModel not found")
            return
        }

        coordinator?.openFeeCurrency(for: networkCurrencyWalletModel, userWalletModel: userWalletModel)
    }
}

extension SendViewModel: SendSummaryRoutable {
    func openStep(_ step: SendStep) {
        guard self.step == .summary else {
            assertionFailure("This code should only be called from summary")
            return
        }

        if let auxiliaryViewAnimatable = auxiliaryViewAnimatable(step) {
            auxiliaryViewAnimatable.setAnimatingAuxiliaryViewsOnAppear()
        }

        openStep(step, stepAnimation: .moveAndFade, updateFee: false)
    }

    func send() {
        guard let screenIdleStartTime else { return }

        let feeValidityInterval: TimeInterval = 60
        let now = Date()
        if now.timeIntervalSince(screenIdleStartTime) <= feeValidityInterval {
            sendModel.send()
            return
        }

        sendModel.updateFees()
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.alert = SendAlertBuilder.makeFeeRetryAlert {
                        self?.send()
                    }
                }
            } receiveValue: { [weak self] result in
                self?.screenIdleStartTime = Date()

                if let oldFee = result.oldFee, result.newFee > oldFee {
                    self?.alert = AlertBuilder.makeOkGotItAlert(message: Localization.sendNotificationHighFeeTitle)
                } else {
                    self?.sendModel.send()
                }
            }
            .store(in: &bag)
    }

    private func auxiliaryViewAnimatable(_ step: SendStep) -> AuxiliaryViewAnimatable? {
        switch step {
        case .amount:
            return sendAmountViewModel
        case .destination:
            return sendDestinationViewModel
        case .fee:
            return sendFeeViewModel
        case .summary:
            return nil
        case .finish:
            return nil
        }
    }
}

extension SendViewModel: NotificationTapDelegate {
    func didTapNotification(with id: NotificationViewId) {}

    func didTapNotificationButton(with id: NotificationViewId, action: NotificationButtonActionType) {
        switch action {
        case .refreshFee:
            feeUpdateSubscription = sendModel.updateFees()
                .mapToVoid()
                .sink()
        case .openFeeCurrency:
            openNetworkCurrency()
        case .reduceAmountBy(let amount, _):
            reduceAmountBy(amount)
        case .reduceAmountTo(let amount, _):
            reduceAmountTo(amount)
        default:
            assertionFailure("Notification tap not handled")
        }
    }

    private func reduceAmountBy(_ amount: Decimal) {
        guard var newAmount = sendModel.validatedAmountValue else { return }

        newAmount = newAmount - Amount(with: walletModel.tokenItem.blockchain, type: walletModel.amountType, value: amount)
        if sendModel.isFeeIncluded, let feeValue = sendModel.feeValue?.amount {
            newAmount = newAmount + feeValue
        }

        fiatCryptoAdapter.setCrypto(newAmount.value)
    }

    private func reduceAmountTo(_ amount: Decimal) {
        var newAmount = amount

        if sendModel.isFeeIncluded, let feeValue = sendModel.feeValue?.amount.value {
            newAmount = newAmount + feeValue
        }

        fiatCryptoAdapter.setCrypto(newAmount)
    }
}

// MARK: - SendStep

private extension SendStep {
    var updateFeeOnLeave: Bool {
        let updateFee: Bool
        switch self {
        case .destination, .amount:
            return true
        case .fee, .summary, .finish:
            return false
        }
    }
}

// MARK: - ValidationError

private extension ValidationError {
    var step: SendStep? {
        switch self {
        case .invalidAmount, .balanceNotFound:
            // Shouldn't happen as we validate and cover amount errors separately, synchronously
            return nil
        case .amountExceedsBalance, .invalidFee, .feeExceedsBalance, .maximumUTXO, .reserve:
            return .fee
        case .dustAmount, .dustChange, .minimumBalance, .totalExceedsBalance:
            return .summary
        }
    }
}
