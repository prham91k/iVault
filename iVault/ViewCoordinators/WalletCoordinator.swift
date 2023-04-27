//
//  WalletCoordinator.swift
//  XWallet
//
//  Created by loj on 16.11.17.
//

import Foundation
import UIKit


public protocol WalletCoordinatorDelegate: AnyObject {
    func walletCoordinatorWalletNuked(walletCoordinator: WalletCoordinator)
}


public class WalletCoordinator: Coordinator {
    
    private let storyboardName = "Wallet"
    private let walletSceneName = "Wallet"
    private let ReceiveSceneName = "Receive"
    private let RecipientSceneName = "Recipient"
    private let AmountSceneName = "Amount"
    private let PaymentIdSceneName = "PaymentId"
    private let SummarySceneName = "Summary"
    private let ScanSceneName = "Scan"
    
    private let pinStoryBoardName = "Onboarding"
    private let pinSceneName = "PIN"

    // This is the `root` view controller of this coordinator
    private var walletVC: WalletVC!
    
    private var moneroBag: MoneroBagProtocol
    private var walletLifecycleService: WalletLifecycleServiceProtocol
    private var propertyStore: PropertyStoreProtocol
    private var secureStore: SecureStoreProtocol
    private var fiatService: FiatServiceProtocol
    private var feeService: FeeServiceProtocol
    private var moneroUriParser: MoneroUriParserProtocol
    private var localizer: Localizable
    private var cachedWalletViewModel : WalletViewModel?
    private let navigationController: UINavigationController
    public var childCoordinators: [Coordinator] = []

    weak var delegate: WalletCoordinatorDelegate?
    
    private lazy var storyboard: UIStoryboard = {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard
    }()
    
    private lazy var storyboardPin: UIStoryboard = {
        let storyboard = UIStoryboard(name: pinStoryBoardName, bundle: nil)
        return storyboard
    }()
    
    init(navigationController: UINavigationController,
         moneroBag: MoneroBagProtocol,
         walletLifecycleService: WalletLifecycleServiceProtocol,
         propertyStore: PropertyStoreProtocol,
         secureStore: SecureStoreProtocol,
         fiatService: FiatServiceProtocol,
         feeService: FeeServiceProtocol,
         moneroUriParser: MoneroUriParserProtocol,
         localizer: Localizable)
    {
        self.navigationController = navigationController
        self.moneroBag = moneroBag
        self.walletLifecycleService = walletLifecycleService
        self.propertyStore = propertyStore
        self.secureStore = secureStore
        self.fiatService = fiatService
        self.feeService = feeService
        self.moneroUriParser = moneroUriParser
        self.localizer = localizer
        self.cachedWalletViewModel = nil
    }
    
    func start() {
        self.showWalletViewController()
        self.startFiatUpdates()
//        self.startFeeEstimationUpdates()
    }
    
    private func showWalletViewController() {
        self.walletVC = (self.storyboard.instantiateViewController(withIdentifier: walletSceneName) as! WalletVC)
        walletVC.delegate = self
        walletVC.localizer = self.localizer
        walletVC.viewModel = self.getWalletViewModel()
        self.navigationController.pushViewController(walletVC, animated: true)
    }
    
    private func getWalletViewModel() -> WalletViewModel? {
        
        guard let wallet = self.moneroBag.wallet  else {
            return nil
        }
        let height = UInt64(self.moneroBag.wallet?.height ?? 0)
        let xmrBalance = CoinFormatter.format(atomicAmount: wallet.balance,
                                             numberOfFractionDigits: Constants.prettyPrintNumberOfFractionDigits)
        let cached = self.cachedWalletViewModel

        if(cached?.blockChainHeight == height && cached?.xmrAmount == xmrBalance) {
            return cached
        }
        
        
        let unlockBalance = CoinFormatter.format(atomicAmount: wallet.unlockedBalance,
                                                 numberOfFractionDigits: Constants.prettyPrintNumberOfFractionDigits)
        
        let history = wallet.history
        
        
        let lockAmount = wallet.balance - wallet.unlockedBalance
        let hasLockedBalance = (lockAmount <= Constants.atomicUnitsPerMonero)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "Y-MM-dd hh:mm:ss"
        let dateString = dateFormatter.string(from: Date())
        Debug.print(s: "[\(dateString)] Have unlocked : \( wallet.unlockedBalance) | balance  : \(wallet.balance) at height : \(height)")
        
        let walletViewModel = WalletViewModel(xmrAmount: xmrBalance,
                                              otherAmount: self.otherAmount(forXMRValue: self.moneroBag.wallet?.balance),
                                              otherCurrency: self.propertyStore.currency,
                                              history: history.all,
                                              hasLockedBalance: hasLockedBalance,
                                              unlockBalance:unlockBalance,
                                              viewTitle: self.localizer.localized("walletView.title"),
                                              viewTitelSyncing: self.localizer.localized("walletView.title.syncing"),
                                              configButtonTitle: "",
                                              sendButtonTitle: self.localizer.localized("walletView.button.send"),
                                              receiveButtonTitle: self.localizer.localized("walletView.button.receive"),
                                              emptyTransactionsText: self.localizer.localized("walletView.emptyInformation"),
                                              blockChainHeight: self.moneroBag.wallet?.height ?? 0,
                                              networkHeight: self.moneroBag.wallet?.networkHeight ?? 0)
//        wallet.refreshWallet();
        self.cachedWalletViewModel = walletViewModel
        return walletViewModel
    }
    
    private func otherAmount(forXMRValue xmrValue: UInt64?) -> String {
        guard let xmrValue = xmrValue else {
            return "---"
        }
        
        let fiatEquivalent = self.fiatService.getFiat(forXMRValue: xmrValue)
        switch fiatEquivalent {
        case .none:
            return "---"
        case let .value(.recent, amount):
            return "\(amount.toCurrency())"
        case let .value(_, amount):
            return "\(amount.toCurrency())"
//            return "\(amount.toCurrency()) [\(self.localizer.localized(age))]"
        }
    }
    
    private func startFiatUpdates() {
        self.fiatService.startUpdating(withIntervalInSeconds: Constants.fiatUpdateIntervalInSeconds,
                                       notificationHandler: self.fiatValueUpdated)
    }
    
    private func stopFiatUpdates() {
        self.fiatService.stopUpdating()
    }
    
    private func fiatValueUpdated() {
        self.cachedWalletViewModel = nil
        let vm = self.getWalletViewModel()
        DispatchQueue.main.async {
            self.walletVC.viewModel = vm
            self.walletVC.viewModelIsUpdated()
        }
    }
    
    private func startFeeEstimationUpdates() {
//        self.feeService.startUpdating(withIntervalInSeconds: Constants.feeUpdateIntervalInSeconds,
//                                                notificationHandler: {} )
    }
    
    private func stopFeeEstimationUpdates() {
//        self.feeService.stopUpdating()
    }
    
    private func showReceiveViewController() {
        let vc = self.storyboard.instantiateViewController(withIdentifier: ReceiveSceneName) as! ReceiveVC
        vc.delegate = self
        vc.qrcImage = QRCGenerator.generate(from: self.moneroBag.wallet?.publicAddress?.address,
                                            scale: 10.0)
        vc.walletAddress = self.moneroBag.wallet?.publicAddress?.address
        vc.backButtonTitle = self.localizer.localized("global.button.back")
        vc.viewTitle = self.localizer.localized("receiveView.title")
        vc.copyButtonTitle = self.localizer.localized("receiveView.button.copyToClipboard")
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func showRecipientViewController() {
        let vc = self.storyboard.instantiateViewController(withIdentifier: RecipientSceneName) as! ReceipientVC
        vc.delegate = self
        vc.backButtonTitle = self.localizer.localized("global.button.back")
        vc.viewTitle = self.localizer.localized("recipientView.title")
        vc.subTitle = self.localizer.localized("recipientView.subTitle")
        vc.instructionText = self.localizer.localized("recipientView.instruction")
        vc.scanQRCodeButtonTitle = self.localizer.localized("recipientView.button.scanQRC")
        vc.pasteFromClipboardButtonTitle = self.localizer.localized("recipientView.button.paste")
        vc.sendToDeveloperButtonTitle = self.localizer.localized("recipientView.sendToDeveloper")
        vc.ok = self.localizer.localized("global.ok")
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func showSettings() {
        let settingsCoordinator = SettingsCoordinator(navigationController: self.navigationController,
                                                      propertyStore: self.propertyStore,
                                                      secureStore: self.secureStore,
                                                      moneroBag: self.moneroBag,
                                                      walletLifecycleService: self.walletLifecycleService,
                                                      localizer: self.localizer)
        settingsCoordinator.delegate = self
        settingsCoordinator.start()
        
        self.add(childCoordinator: settingsCoordinator)
    }
}


extension WalletCoordinator: WalletDelegate {
    
    public func walletUpdated() {
        let vm = self.getWalletViewModel()

        DispatchQueue.main.async {
            self.walletVC.viewModel = vm
            self.walletVC.viewModelIsUpdated()
        }
    }

    public func walletSyncing(initialHeight: UInt64, walletHeight: UInt64, blockChainHeight: UInt64) {
        DispatchQueue.main.async {
            self.walletVC.walletSyncing(initialHeight: initialHeight,
                                        walletHeight: walletHeight,
                                        blockChainHeight: blockChainHeight)
        }
    }
    
    public func walletSyncCompleted() {
        DispatchQueue.main.async {
            self.walletVC.walletSyncCompleted()
        }
    }
}


extension WalletCoordinator: WalletVCDelegate {
    
    func walletVCSettingsButtonTouched() {
        self.stopFiatUpdates()
        self.showSettings()
    }
    
    func walletVCSendTouched() {
        self.moneroBag.payment = nil
        self.showRecipientViewController()
    }
    
    func walletVCReceiveTouched() {
        self.showReceiveViewController()
    }

    func walletVCWillEnterForeground() {
        if let wallet = self.moneroBag.wallet {
            wallet.register(delegate: self)
        }
    }
}


extension WalletCoordinator: ReceiveVCDelegate {

    func receiveVCBackTouched() {
        self.navigationController.popViewController(animated: true)
    }
    
    func receiveVCCopyToClipboardTouched() {
        if let walletAddress = self.moneroBag.wallet?.publicAddress?.address {
            UIPasteboard.general.string = walletAddress
        }
    }
}


extension WalletCoordinator: ReceipientVCDelegate {
    
    func receipientVCBackTouched() {
        self.navigationController.popViewController(animated: true)
    }
    
    func receipientVCScanQRCodeTouched() {
        self.moneroBag.payment = self.getEmptyPayment()
        
        let vc = self.storyboard.instantiateViewController(withIdentifier: ScanSceneName) as! ScanVC
        vc.delegate = self
        vc.backButtonTitle = self.localizer.localized("global.button.back")
        vc.viewTitle = self.localizer.localized("scanView.title")
        vc.notSupportedTitle = self.localizer.localized("scanView.notSupported.title")
        vc.notSupportedMessage = self.localizer.localized("scanView.notSupported.message")
        vc.ok = self.localizer.localized("global.ok")
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func receipientVCPasteFromClipboardTouched(viewController: ReceipientVC) {
        guard let pasteboardContent = UIPasteboard.general.string else {
            viewController.show(message: self.localizer.localized("recipientView.message.pasteboardEmpty"))
            return
        }

        let result = self.moneroUriParser.process(pasteboardContent)
        if result.parseResult == .ok {
            self.showPasteboardResult(parameters: result.payment,
                                      onViewController: viewController)
        } else {
            self.showPasteboardError(parseResult: result.parseResult,
                                     parameters: result.payment,
                                     onViewController: viewController)
        }
    }

    private func showPasteboardResult(parameters: PaymentParameters, onViewController viewController: UIViewController) {
        let walletAddress = parameters.walletAddress!
        var message = "\(self.localizer.localized("pasteFromClipboard.address"))\n\(walletAddress)"
        if let paymentId = parameters.paymentId {
            message.append("\n\n\(self.localizer.localized("pasteFromClipboard.paymentId"))\n\(paymentId)")
        }
        if let amount = parameters.amount {
            message.append("\n\n\(self.localizer.localized("pasteFromClipboard.amount"))\n\(amount)")
        }
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: self.localizer.localized("pasteFromClipboard.button.accept"), style: .default, handler: { action in
            self.moneroBag.payment = self.makePayment(withParameters: parameters)
            self.showAmountViewController()
        }))
        alert.addAction(UIAlertAction(title: self.localizer.localized("global.cancel"), style: .cancel, handler: { action in
            self.moneroBag.payment = self.getEmptyPayment()
        }))
        viewController.present(alert, animated: true, completion: nil)
    }

    private func showPasteboardError(parseResult: MoneroUriParseResult, parameters: PaymentParameters, onViewController viewController: UIViewController) {
        let messages = [MoneroUriParseResult.ok:"",
                        .invalidWalletAddress:self.localizer.localized("global.invalidWalletAddress"),
                        .invalidPaymentId:self.localizer.localized("global.invalidPaymentId"),
                        .invalidAmount:self.localizer.localized("global.invalidAmount"),
                        .invalidDescription:self.localizer.localized("global.invalidDescription")]
        let message = messages[parseResult]

        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: self.localizer.localized("global.ok"), style: .default, handler: { action in
        }))
        viewController.present(alert, animated: true, completion: nil)
    }

    func receipientVCSendToDeveloperTouched(viewController: ReceipientVC) {
        self.moneroBag.payment = self.getEmptyPayment()
        self.moneroBag.payment?.targetAddress = Constants.donationWalletAddress
        self.showAmountViewController()
    }
    
    private func showAmountViewController() {
        let vc = self.storyboard.instantiateViewController(withIdentifier: AmountSceneName) as! AmountVC
        vc.delegate = self
        vc.backButtonTitle = self.localizer.localized("global.button.back")
        vc.nextButtonTitle = self.localizer.localized("amountView.button.next")
        vc.viewTitle = self.localizer.localized("amountView.title")
        vc.currencyText = "XLA"
        vc.amountText = String(self.moneroBag.payment?.amountInAtomicUnits?.toXMR() ?? Double(0.0))
        vc.amountOtherText = "\(self.propertyStore.currency) \(self.otherAmount(forXMRValue: 0))"
        
        let formattedAmounts = self.formattedAmounts()
        vc.totalAmountAvailableButtonTitle = "XLA \(formattedAmounts.available)"
        vc.balanceTitle = self.localizer.localized("amountView.balance")
        vc.balanceValueText = formattedAmounts.balance
        
//        vc.unlockBalanceTitle = self.localizer.localized("amountView.unlockBalance")
//        vc.unlockBalanceValueText = formattedAmounts.unlockBalance
        
        vc.estimatedFeeTitle = self.localizer.localized("amountView.estimatedFee")
        vc.estimatedFeeValueText = formattedAmounts.fee
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func getEmptyPayment() -> PaymentProtocol {
        return Payment()
    }

    private func makePayment(withParameters parameters: PaymentParameters) -> PaymentProtocol {
        let payment = Payment()
        
        payment.targetAddress = parameters.walletAddress
        payment.paymentId = parameters.paymentId
        if let amountAsString = parameters.amount, let amountAsDouble = Double(amountAsString) {
            payment.amountInAtomicUnits = amountAsDouble.toXMR()
        }

        return payment
    }
    
    private func amounts() -> (balance: UInt64, fee: UInt64, available: UInt64) {
        let balance = self.moneroBag.wallet?.balance ?? 0
        let fee = self.feeService.getFeeInAtomicUnits(forMessageSizeInKB: Constants.estimatedMessageSizeInKB)
        let available = balance > fee ? balance - fee : 0

        return (balance: balance, fee: fee, available: available)
    }
    
    private func formattedAmounts() -> (balance: String, fee: String, available: String) {
        let amounts = self.amounts()
        
        let balanceFormatted = CoinFormatter.format(atomicAmount: amounts.balance, numberOfFractionDigits: Constants.numberOfFractionDigits)
        let feeFormatted = CoinFormatter.format(atomicAmount: amounts.fee, numberOfFractionDigits: Constants.numberOfFractionDigits)
        let availableFormatted = CoinFormatter.format(atomicAmount: amounts.available, numberOfFractionDigits: Constants.numberOfFractionDigits)
        
        return (balance: balanceFormatted, fee: feeFormatted, available: availableFormatted)
    }
}


extension WalletCoordinator: ScanVCDelegate {
    
    public func scanVCDelegateBackButtonTouched() {
        self.navigationController.popViewController(animated: true)
    }
    
    public func scanVCDelegateUriDetected(uri: String, viewController: ScanVC) {
        let result = self.moneroUriParser.process(uri)
        if result.parseResult == .ok {
            self.showScanResult(parameters: result.payment,
                                onViewController: viewController)
        } else {
            self.showScanError(scanResult: result.parseResult,
                               parameters: result.payment,
                               onViewController: viewController)
        }
    }

    private func showScanResult(parameters: PaymentParameters, onViewController viewController: ScanVC) {
        let walletAddress = parameters.walletAddress!
        var message = "\(self.localizer.localized("scan.address"))\n\(walletAddress)"
        if let paymentId = parameters.paymentId {
            message.append("\n\n\(self.localizer.localized("scan.paymentId"))\n\(paymentId)")
        }
        if let amount = parameters.amount {
            message.append("\n\n\(self.localizer.localized("scan.amount"))\n\(amount)")
        }
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: self.localizer.localized("scan.accept"), style: .default, handler: { action in
            self.moneroBag.payment = self.makePayment(withParameters: parameters)
            self.navigationController.popViewController(animated: true)
            self.showAmountViewController()
        }))
        alert.addAction(UIAlertAction(title: self.localizer.localized("global.cancel"), style: .cancel, handler: { action in
            viewController.startScanning()
        }))
        viewController.present(alert, animated: true, completion: nil)
    }

    private func showScanError(scanResult: MoneroUriParseResult, parameters: PaymentParameters, onViewController viewController: ScanVC) {
        let messages = [MoneroUriParseResult.ok:"",
                        .invalidWalletAddress:self.localizer.localized("global.invalidWalletAddress"),
                        .invalidPaymentId:self.localizer.localized("global.invalidPaymentId"),
                        .invalidAmount:self.localizer.localized("global.invalidAmount"),
                        .invalidDescription:self.localizer.localized("global.invalidDescription")]
        let message = messages[scanResult]

        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: self.localizer.localized("scan.retake"), style: .default, handler: { action in
            viewController.startScanning()
        }))
        viewController.present(alert, animated: true, completion: nil)
    }

    private func isValid(walletAddress: String) -> Bool {
        let isValidWalletAddress = monero_isValidWalletAddress(walletAddress)
        return isValidWalletAddress
    }
}


extension WalletCoordinator: AmountVCDelegate {
    
    func amountVCBackTouched() {
        self.navigationController.popViewController(animated: true)
    }
    
    func amountVCNextButtonTouched(formattedAmount: String, viewController: AmountVC) {
        self.moneroBag.payment?.amountInAtomicUnits = CoinFormatter.fromFormatted(amount: formattedAmount)
        self.showPaymentIdViewController()
    }
    
    func amountVCTotalAmountButtonTouched(viewController: AmountVC) {
        let amounts = self.amounts()
        let formattedAmounts = self.formattedAmounts()
        
        viewController.amountText = formattedAmounts.available
        viewController.amountOtherText = "\(self.propertyStore.currency) \(self.otherAmount(forXMRValue: amounts.available))"
        viewController.refresh()
        viewController.nextAllowed()
    }

    func amountVCAmountValueChanged(amount: Double?, viewController: AmountVC) {
        guard let requestedXmrDouble = amount else {
            viewController.showFiatValue("---", forCurrency: self.propertyStore.currency)
            viewController.nextNotAllowed()
            return
        }

        let requestedXmrInAtomicUnits = (requestedXmrDouble).toXMR()
        let fiatValue = self.otherAmount(forXMRValue: requestedXmrInAtomicUnits)
        viewController.showFiatValue(fiatValue, forCurrency: self.propertyStore.currency)

        let available = self.moneroBag.wallet?.balance ?? 0
        if requestedXmrInAtomicUnits != nil && requestedXmrInAtomicUnits! > 0 && requestedXmrInAtomicUnits! <= available {
            viewController.nextAllowed()
        } else {
            viewController.nextNotAllowed()
        }
    }

    
    private func showPaymentIdViewController() {
        let vc = self.storyboard.instantiateViewController(withIdentifier: PaymentIdSceneName) as! PaymentIdVC
        vc.delegate = self
        vc.backButtonTitle = self.localizer.localized("global.button.back")
        vc.nextButtonTitle = self.localizer.localized("paymentIdView.button.next")
        vc.viewTitle = self.localizer.localized("paymentIdView.title")
        vc.subTitle = self.localizer.localized("paymentIdView.subTitle")
        vc.instructionText = self.localizer.localized("paymentIdView.instruction")
        vc.paymentIdPlaceholderText = self.localizer.localized("paymentIdView.paymentId.placeholder")
        vc.paymentIdText = self.moneroBag.payment?.paymentId ?? ""
        vc.pasteFromClipboardButtonTitle = self.localizer.localized("paymentIdView.button.pasteFromClipboard")
        vc.ok = self.localizer.localized("global.ok")
        self.navigationController.pushViewController(vc, animated: true)
    }
}


extension WalletCoordinator: PaymentIdVCDelegate {
    
    func paymentIdVCBackButtonTouched() {
        self.navigationController.popViewController(animated: true)
    }
    
    func paymentIdVCNextButtonTouched(paymentId: String, viewController: PaymentIdVC) {
        if !self.isValid(paymentId: paymentId) {
            viewController.show(message: self.localizer.localized("paymentId.invalid"))
            return
        }
        self.moneroBag.payment?.paymentId = paymentId

        self.prepareSummaryViewController(viewController: viewController)
    }
    
    private func prepareSummaryViewController(viewController: ActivityIndicatorProtocol) {
        guard let amount = self.moneroBag.payment?.amountInAtomicUnits else {
            return
        }
        
        viewController.showActivityIndicator()
        
        DispatchQueue.global(qos: .background).async {
            let key = monero_createTransaction(self.moneroBag.payment?.targetAddress,
                                               self.moneroBag.payment?.paymentId,
                                               amount,
                                               Constants.mixinCount,
                                               Constants.defaultTransactionPriority)
            Debug.print(s: "Sending amount :\(amount)")
            self.moneroBag.payment?.keyOfPendingTransaction = key
            let networkFee = monero_getTransactionFee(key)
            self.moneroBag.payment?.networkFeeInAtomicUnits = networkFee < 0 ? UInt64(0) : UInt64(networkFee)

            DispatchQueue.main.async {
                viewController.hideActivityIndicator()
                self.showSummaryViewController()
            }
        }
    }
    
    func paymentIdVCPasteFromClipboardButtonTouched(viewController: PaymentIdVC) {
        guard let clipboardString = UIPasteboard.general.string else { return }
        
        if self.isValid(paymentId: clipboardString) {
            viewController.paymentIdText = clipboardString
            viewController.refresh()
        } else {
            viewController.show(message: self.localizer.localized("paymentId.invalid.fromClipboard"))
        }
    }
    
    private func isValid(paymentId: String) -> Bool {
        if paymentId == "" {
            return true
        }
        
        let isValid = monero_isValidPaymentId(paymentId)
        return isValid
    }
    
    private func showSummaryViewController() {
        let vc = self.storyboard.instantiateViewController(withIdentifier: SummarySceneName) as! SummaryVC
        vc.delegate = self
        vc.backButtonTitle = self.localizer.localized("global.button.back")
        vc.viewTitle = self.localizer.localized("summaryView.title")
        vc.subTitle = self.localizer.localized("summaryView.subTitle")
        vc.addressText = self.localizer.localized("summaryView.address")
        vc.addressValueText = self.moneroBag.payment?.targetAddress ?? "---"
        vc.paymentIdText = self.localizer.localized("summaryView.paymentId")
        vc.paymentIdValueText = self.moneroBag.payment?.paymentId ?? "---"
        vc.subtotalText = self.localizer.localized("summaryView.subtotal")
        let amount = CoinFormatter.format(atomicAmount: self.moneroBag.payment?.amountInAtomicUnits ?? 0,
                                         numberOfFractionDigits: Constants.numberOfFractionDigits)
        vc.subtotalValueText = "XLA \(amount)"
        vc.networkFeeText = self.localizer.localized("summaryView.networkFee")
        let networkFee = CoinFormatter.format(atomicAmount: self.moneroBag.payment?.networkFeeInAtomicUnits ?? 0,
                                             numberOfFractionDigits: Constants.numberOfFractionDigits)
        vc.networkFeeValueText = "XLA \(networkFee)"
        vc.confirmButtonTitle = self.localizer.localized("summaryView.button.confirm")
        vc.totalText = self.localizer.localized("summaryView.total")
        let totalAmount = CoinFormatter.format(atomicAmount: self.moneroBag.payment?.amountTotalInAtomicUnits ?? 0,
                                              numberOfFractionDigits: Constants.numberOfFractionDigits)
        vc.totalValueText = "XLA \(totalAmount)"
        vc.balanceIsSufficient = self.balanceIsSufficient()
        vc.balanaceInsufficientText = self.localizer.localized("summaryView.balanceInsufficient")
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func balanceIsSufficient() -> Bool {
        let available = self.moneroBag.wallet?.unlockedBalance ?? 0
        let requested = self.moneroBag.payment?.amountTotalInAtomicUnits ?? 0
        
        Debug.print(s: "A: \(available) R: \(requested)")

        guard let key = self.moneroBag.payment?.keyOfPendingTransaction else {
            return false
        }
        if key < 0 {
            return false
        }
        
        return available >= requested
    }
}


extension WalletCoordinator: SummaryVCDelegate {
    
    func summaryVCConfirmButtonTouched() {
        self.showConfirmWithPinViewController()
    }
    
    func summaryVCBackButtonTouched() {
        self.navigationController.popViewController(animated: true)
    }
    
    private func showConfirmWithPinViewController() {
        guard let appPin = self.secureStore.appPin else {
            return
        }
        
        let vc = self.storyboardPin.instantiateViewController(withIdentifier: pinSceneName) as! PinVC
        vc.pinMode = .confirmPin(withInitialPin: appPin)
        vc.pinAutoConfirm = false
        vc.progress = nil
        vc.delegate = self
        vc.viewTitle = self.localizer.localized("confirmView.title")
        vc.subTitle = self.localizer.localized("confirmView.subTitle")
        vc.instructionText = ""
        vc.backButtonTitle = self.localizer.localized("global.button.back")
        vc.nextButtonTitle = self.localizer.localized("confirmView.button.next")
        self.navigationController.pushViewController(vc, animated: true)
    }
}


extension WalletCoordinator: PinVCDelegate {
    
    public func pinVCButtonNextTouched(pinEntered pin: String, viewController: PinVC) {
        guard let key = self.moneroBag.payment?.keyOfPendingTransaction else {
            //@@TODO "notify that something went wrong"
            return
        }

        //@@TODO "perform payment async"
        monero_commitPendingTransaction(key)

        self.goBackToWalletViewController()
    }
    
    public func pinVCButtonBackTouched() {
        self.navigationController.popViewController(animated: true)
    }
    
    private func goBackToWalletViewController() {
        self.navigationController.popToViewController(self.walletVC, animated: true)
        
        self.walletUpdated()
    }
}


extension WalletCoordinator: SettingsCoordinatorDelegate {
    
    public func settingsCoordinatorSettingsCompleted(settingsCoordinator: SettingsCoordinator) {
        if let walletVC = self.walletVC {
            self.navigationController.popToViewController(walletVC, animated: true)
        }
        self.remove(childCoordinator: settingsCoordinator)
        self.startFiatUpdates()
    }

    public func settingsCoordinatorWalletNuked(settingsCoordinator: SettingsCoordinator) {
        self.stopFeeEstimationUpdates()
        self.remove(childCoordinator: settingsCoordinator)
        self.delegate?.walletCoordinatorWalletNuked(walletCoordinator: self)
    }

    public func settingsCoordinatorLanguageDidChange(settingsCoordinator: SettingsCoordinator) {
        self.walletVC.viewModel = self.getWalletViewModel()
        self.walletVC.refresh()
    }
}
