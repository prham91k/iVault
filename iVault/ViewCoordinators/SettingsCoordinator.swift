//
//  SettingsCoordinator.swift
//  XWallet
//
//  Created by loj on 21.01.18.
//

import Foundation
import UIKit


public protocol SettingsCoordinatorDelegate: AnyObject {
    func settingsCoordinatorSettingsCompleted(settingsCoordinator: SettingsCoordinator)
    func settingsCoordinatorWalletNuked(settingsCoordinator: SettingsCoordinator)
    func settingsCoordinatorLanguageDidChange(settingsCoordinator: SettingsCoordinator)
}


public class SettingsCoordinator: Coordinator {
    
    private let storyboardName = "Settings"
    private let settingsSceneName = "Settings"
    
    private let singleSelectTableViewStoryboardName = "SingleSelectTableView"
    private let singleSelectTableViewSceneName = "SingleSelectTableView"

    private let selectNodeStoryboardName = "SelectNode"
    private let selectNodeSceneName = "SelectNode"

    private let navigationController: UINavigationController
    public var childCoordinators: [Coordinator] = []
    
    public weak var delegate: SettingsCoordinatorDelegate?
    
    private var propertyStore: PropertyStoreProtocol
    private var secureStore: SecureStoreProtocol
    private var walletLifecycleService: WalletLifecycleServiceProtocol
    private var moneroBag: MoneroBagProtocol
    private var localizer: Localizable
    private var settingsVC: SettingsVC?
    
    init(navigationController: UINavigationController,
         propertyStore: PropertyStoreProtocol,
         secureStore: SecureStoreProtocol,
         moneroBag: MoneroBagProtocol,
         walletLifecycleService: WalletLifecycleServiceProtocol,
         localizer: Localizable)
    {
        self.navigationController = navigationController
        self.propertyStore = propertyStore
        self.secureStore = secureStore
        self.moneroBag = moneroBag
        self.walletLifecycleService = walletLifecycleService
        self.localizer = localizer
    }
    
    private lazy var storyboard: UIStoryboard = {
        let storyboard = UIStoryboard(name: self.storyboardName, bundle: nil)
        return storyboard
    }()

    private lazy var singleSelectTableViewStoryboard: UIStoryboard = {
        let storyboard = UIStoryboard(name: self.singleSelectTableViewStoryboardName, bundle: nil)
        return storyboard
    }()
    
    private lazy var selectNodeStoryboard: UIStoryboard = {
        let storyboard = UIStoryboard(name: selectNodeStoryboardName, bundle: nil)
        return storyboard
    }()
    
    public func start() {
        self.showSettingsViewController()
    }
    
    private func showSettingsViewController() {
        self.settingsVC = self.storyboard.instantiateViewController(withIdentifier: settingsSceneName) as? SettingsVC
        if let vc = self.settingsVC {
            vc.viewModel = self.makeSettingsViewModel()

            self.navigationController.pushViewController(vc, animated: true)
        }
    }

    private func makeSettingsViewModel() -> SettingsViewModel {
        var viewModel = SettingsViewModel()
        viewModel.delegate = self
        viewModel.viewTitle = self.localizer.localized("settingsView.title")
        viewModel.backButtonTitle = ""
        viewModel.fiatConversionUnitsCellTitle = self.localizer.localized("settingsView.fiat.title")
        viewModel.fiatConversionUnitsSelectedValue = self.propertyStore.currency
        viewModel.languageCellTitle = self.localizer.localized("settingsView.language.title")
        viewModel.languageSelectedValue = self.localizer.localized("language.\(self.propertyStore.language)")
        viewModel.displayRecoverySeedCellTitle = self.localizer.localized("settingsView.displayRecoverySeed.title")
        viewModel.displayRecoverySeedCellSubTitle = self.localizer.localized("settingsView.displayRecoverySeed.subTitle")
        viewModel.displayRecoverySeedCellButtonTitle = self.localizer.localized("settingsView.displayRecoverySeed.button")
        viewModel.resetPinCellTitle = self.localizer.localized("settingsView.resetPin.title")
        viewModel.resetPinCellButtonTitle = self.localizer.localized("settingsView.resetPin.button")
        viewModel.tfaSupportCellTitle = self.localizer.localized("settingsView.tfaSupport.title")
        viewModel.tfaSupportButtonTitle = self.localizer.localized("settingsView.tfaSupport.button")
        viewModel.selectNodeCellTitle = self.localizer.localized("settingsView.selectNode.title")
        viewModel.selectNodeCellSubTitle = self.localizer.localized("settingsView.selectNode.subTitle")
        viewModel.selectNodeCellButtonTitle = self.localizer.localized("settingsView.selectNode.button")
        
        viewModel.rescanWalletCellTitle = self.localizer.localized("settingsView.rescanWallet.title")
        viewModel.rescanWalletCellSubTitle = self.localizer.localized("settingsView.rescanWallet.subTitle")
        viewModel.rescanWalletCellButtonTitle = self.localizer.localized("settingsView.rescanWallet.button")
        
        viewModel.maxTrxHistoryCellTitle = self.localizer.localized("settingsView.maxTrxHistory.title")
        viewModel.maxTrxHistoryCellButtonTitle = self.localizer.localized("settingsView.maxTrxHistory.button")
        
        
        viewModel.nukeXWalletCellTitle = self.localizer.localized("settingsView.nukeXWallet.title")
        viewModel.nukeXWalletCellSubTitle = self.localizer.localized("settingsView.nukeXWallet.subTitle")
        viewModel.nukeXWalletCellButtonTitle = self.localizer.localized("settingsView.nukeXWallet.button")
        viewModel.feedbackCellTitle = self.localizer.localized("settingsView.feedback.title")
        viewModel.feedbackCellButtonTitle = Constants.feedbackEmail
        viewModel.feedbackSubject = self.localizer.localized("settingsView.feedback.button")
        viewModel.feedbackMessageBody = self.localizer.localized("settingsView.feedback.messageBody")
        viewModel.feedbackDescription = self.localizer.localized("settingsView.feedback.description")
        viewModel.feedbackShowFAQTitle = self.localizer.localized("settingsView.feedback.showFAQTitle")
        viewModel.feedbackSendTitle = self.localizer.localized("settingsView.feedback.sendTitle")
        viewModel.feedbackCancelTitle = self.localizer.localized("global.cancel")
        viewModel.privacyCellTitle = self.localizer.localized("settingsView.privacy.title")
        viewModel.privacyCellButtonTitle = self.localizer.localized("settingsView.privacy.button")
        viewModel.emailFailedTitle = self.localizer.localized("settingsView.emailFailed.title")
        viewModel.emailFailedMessage = self.localizer.localized("settingsView.emailFailed.message")
        viewModel.ok = self.localizer.localized("global.ok")
        return viewModel
    }
    
    private func showFiatConversionUnitsViewController() {
        let vc = self.singleSelectTableViewStoryboard.instantiateViewController(withIdentifier: singleSelectTableViewSceneName) as! SingleSelectionTableViewVC
        vc.delegate = self
        vc.viewTitle = self.localizer.localized("fiatConversionUnitsView.title")
        vc.backButtonTitle = ""
        vc.cellValues = TableViewDataSource(dictionary: Constants.currencies)
        vc.currentId = self.propertyStore.currency
        vc.selectionChangedAction = { self.switchTo(currency: vc.currentId) }
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func switchTo(currency: String?) {
        if let currency = currency {
            self.propertyStore.currency = currency
        }
        self.propertyStore.lastFiatFactor = nil
        self.propertyStore.lastFiatUpdate = nil
    }
    
    private func showLanguageViewController() {
        let vc = self.singleSelectTableViewStoryboard.instantiateViewController(withIdentifier: singleSelectTableViewSceneName) as! SingleSelectionTableViewVC
        vc.delegate = self
        vc.viewTitle = self.localizer.localized("languageView.title")
        vc.backButtonTitle = ""
        vc.cellValues = TableViewDataSource(dictionary: self.localizer.localized(Constants.languages))
        vc.currentId = self.propertyStore.language
        vc.selectionChangedAction = {
            self.switchTo(language: vc.currentId)
            self.settingsVC?.viewModel = self.makeSettingsViewModel()
            self.settingsVC?.refresh()
            self.delegate?.settingsCoordinatorLanguageDidChange(settingsCoordinator: self)
        }
        
        self.navigationController.pushViewController(vc, animated: true)
    }

    private func switchTo(language: String?) {
        guard let language = language else { return }
        self.propertyStore.language = language
        self.localizer.use(languageId: language)
    }
    
    private func showSelectNodeViewController() {
        let vc = self.selectNodeStoryboard.instantiateViewController(withIdentifier: selectNodeSceneName) as! SelectNodeVC
        vc.delegate = self
        vc.viewTitle = self.localizer.localized("selectNodeView.title")
        vc.backButtonTitle = ""
        vc.defaultsButtonTitle = self.localizer.localized("selectNodeView.button.defaults")
        vc.address = self.propertyStore.nodeAddress
        vc.addressLabelTitle = self.localizer.localized("selectNodeView.address")
        vc.userId = self.secureStore.nodeUserId
        vc.userIdLabelTitle = self.localizer.localized("selectNodeView.userId")
        vc.password = self.secureStore.nodePassword
        vc.passwordLabelTitle = self.localizer.localized("selectNodeView.password")
        vc.connectButtonTitle = self.localizer.localized("selectNodeView.button.connect")
        
        self.navigationController.pushViewController(vc, animated: true)
    }
}


extension SettingsCoordinator: SettingsVCProtocol {

    func settingsVCBackButtonTouched() {
        self.delegate?.settingsCoordinatorSettingsCompleted(settingsCoordinator: self)
    }
    
    func settingsVCFiatConversionUnitsSelectionTouched() {
        self.showFiatConversionUnitsViewController()
    }
    
    func settingsVCLanguageSelectionTouched() {
        self.showLanguageViewController()
    }
    
    func settingsVCRevealRecoverySeedButtonTouched() {
        guard let wallet = self.moneroBag.wallet else { return }
        let revealSeedCoordinator = RevealSeedCoordinator(navigationController: self.navigationController,
                                                          secureStore: self.secureStore,
                                                          wallet: wallet,
                                                          localizer: self.localizer)
        revealSeedCoordinator.delegate = self
        revealSeedCoordinator.start()
        
        self.add(childCoordinator: revealSeedCoordinator)
    }
    
    func settingsVCChangePinButtonTouched() {
        let changePinCoordinator = ChangePinCoordinator(navigationController: self.navigationController,
                                                        secureStore: self.secureStore,
                                                        localizer: self.localizer)
        changePinCoordinator.delegate = self
        changePinCoordinator.start()
        
        self.add(childCoordinator: changePinCoordinator)
    }
    
    func settingsVC2FASupportButtonTouched() {
        let configure2FACoordinator = Configure2FACoordinator(navigationController: self.navigationController,
                                                              secureStore: self.secureStore,
                                                              watchCommunicationService: IocContainer.instance.watchCommunicationService,
                                                              localizer: self.localizer)
        configure2FACoordinator.delegate = self
        configure2FACoordinator.start()
        
        self.add(childCoordinator: configure2FACoordinator)
    }

    func settingsVCSelectNodeButtonTouched() {
        self.showSelectNodeViewController()
    }
    
    func settingsVCRescanWalletButtonTouched() {
        guard let wallet = self.moneroBag.wallet else { return }
        let blockChainHeight: UInt64 = wallet.networkHeight
        let walletHeight : UInt64 = wallet.height
        
        let difference = blockChainHeight.subtractingReportingOverflow(walletHeight)
        let walletIsSynced = difference.overflow || difference.partialValue < 2_000
        if(!walletIsSynced) {
            Debug.print(s: "Wallet is not yet asynced")
            return
        }
        
        Debug.print(s: "Rescan wallet")
        wallet.rescan()
    }
    
    func settingsVCMaxTrxHistoryButtonTouched() {
        Debug.print(s: "Setting Max History")
    }
    
    func settingsVCNukeXWalletButtonTouched() {
        guard let wallet = self.moneroBag.wallet else { return }
        let nukeWalletCoordinator = NukeWalletCoordinator(navigationController: self.navigationController,
                                                          wallet: wallet,
                                                          secureStore: self.secureStore,
                                                          propertyStore: self.propertyStore,
                                                          localizer: self.localizer)
        nukeWalletCoordinator.delegate = self
        nukeWalletCoordinator.start()
        
        self.add(childCoordinator: nukeWalletCoordinator)
    }
}


extension SettingsCoordinator: SingleSelectionTableViewVCProtocol {
    
    func singleSelectionTableViewVCBackButtonTouched() {
        if let settingsVC = self.settingsVC {
            self.navigationController.popToViewController(settingsVC, animated: true)
        }

        let viewModel = self.makeSettingsViewModel()
        self.settingsVC?.viewModel = viewModel
        self.settingsVC?.refresh()
    }
}


extension SettingsCoordinator: RevealSeedCoordinatorDelegate {
    
    public func revealSeedCoordinatorDone(revealSeedCoordinator: RevealSeedCoordinator) {
        if let settingsVC = self.settingsVC {
            self.navigationController.popToViewController(settingsVC, animated: true)
        }
        self.remove(childCoordinator: revealSeedCoordinator)
    }
}


extension SettingsCoordinator: ChangePinCoordinatorDelegate {

    public func changePinCoordinatorDone(changePinCoordinator: ChangePinCoordinator) {
        if let settingsVC = self.settingsVC {
            self.navigationController.popToViewController(settingsVC, animated: true)
        }
        self.remove(childCoordinator: changePinCoordinator)
    }
}


extension SettingsCoordinator: Configure2FACoordinatorDelegate {
    
    public func configure2FACoordinatorDone(configure2FACoordinator: Configure2FACoordinator) {
        if let settingsVC = self.settingsVC {
            self.navigationController.popToViewController(settingsVC, animated: true)
        }
        self.remove(childCoordinator: configure2FACoordinator)
    }
}


extension SettingsCoordinator: NukeWalletCoordinatorDelegate {
    
    public func nukeWalletCoordinatorCancelled(nukeWalletCoordinator: NukeWalletCoordinator) {
        if let settingsVC = self.settingsVC {
            self.navigationController.popToViewController(settingsVC, animated: true)
        }
        self.remove(childCoordinator: nukeWalletCoordinator)
    }
    
    public func nukeWalletCoordinatorWalletNuked(nukeWalletCoordinator: NukeWalletCoordinator) {
        self.remove(childCoordinator: nukeWalletCoordinator)
        self.delegate?.settingsCoordinatorWalletNuked(settingsCoordinator: self)
    }
}


extension SettingsCoordinator: SelectNodeVCDelegate {
    
    func selectNodeVCBackButtonTouched() {
        if let settingsVC = self.settingsVC {
            self.navigationController.popToViewController(settingsVC, animated: true)
        }
    }
    
    func selectNodeVCRestoreDefaultsButtonTouched(selectNodeVC: SelectNodeVC) {
        selectNodeVC.address = Constants.defaultNodeAddress
        selectNodeVC.userId = Constants.defaultNodeUserId
        selectNodeVC.password = Constants.defaultNodePassword
        selectNodeVC.refresh()
    }
    
    func selectNodeVCConnectButtonTouched(address: String,
                                          userId: String,
                                          password: String,
                                          selectNodeVC: SelectNodeVC)
    {
        self.storeNodeSettings(address: address, userId: userId, password: password)
        self.redirectNode(selectNodeVC: selectNodeVC)
    }
    
    private func storeNodeSettings(address: String, userId: String, password: String) {
        self.propertyStore.nodeAddress = address
        self.secureStore.nodeUserId = userId
        self.secureStore.nodePassword = password
    }
    
    private func redirectNode(selectNodeVC: SelectNodeVC) {
        selectNodeVC.showActivityIndicator()
        
        DispatchQueue.global(qos: .background).async {
            self.closeWallet()
            self.reopenWalletWithNewDaemonConfig()
            
            DispatchQueue.main.async {
                selectNodeVC.hideActivityIndicator()
            }
        }
    }
    
    private func closeWallet() {
        guard let wallet = self.moneroBag.wallet else {
            return
        }
        self.walletLifecycleService.lock(wallet: wallet)
    }
    
    private func reopenWalletWithNewDaemonConfig() {
        guard let walletPassword = self.secureStore.walletPassword else {
            return
        }
        guard let wallet = self.walletLifecycleService.unlockWallet(withPassword: walletPassword) else {
            return
        }
        self.moneroBag.wallet = wallet
    }
}
