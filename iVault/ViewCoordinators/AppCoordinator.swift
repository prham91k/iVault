//
//  AppCoordinator.swift
//  XWallet
//
//  Created by loj on 22.10.17.
//

import Foundation
import UIKit


public class AppCoordinator: Coordinator {

    private let legalStoryboardName = "Legal"
    private let legalSceneName = "Legal"
    
    private var moneroBag: MoneroBagProtocol
    private var onboardingService: OnboardingServiceProtocol
    private var propertyStore: PropertyStoreProtocol
    private var secureStore: SecureStoreProtocol
    private var fileHandling: FileHandlingProtocol
    private var walletLifecycleService: WalletLifecycleServiceProtocol
    private var fiatService: FiatServiceProtocol
    private var feeService: FeeServiceProtocol
    private var moneroUriParser: MoneroUriParserProtocol
    private var twoFactorAuthenticationService: TwoFactorAuthenticationServiceProtocol
    private var localizer: Localizable
    
    private let navigationController: UINavigationController
    public var childCoordinators: [Coordinator] = []

    public init(navigationController: UINavigationController,
                moneroBag: MoneroBagProtocol,
                onboardingService: OnboardingServiceProtocol,
                propertyStore: PropertyStoreProtocol,
                secureStore: SecureStoreProtocol,
                fileHandling: FileHandlingProtocol,
                walletLifecycleService: WalletLifecycleServiceProtocol,
                fiatService: FiatServiceProtocol,
                feeService: FeeServiceProtocol,
                moneroUriParser: MoneroUriParserProtocol,
                twoFactorAuthenticationService: TwoFactorAuthenticationServiceProtocol,
                localizer: Localizable)
    {
        self.navigationController = navigationController
        self.moneroBag = moneroBag
        self.onboardingService = onboardingService
        self.propertyStore = propertyStore
        self.secureStore = secureStore
        self.fileHandling = fileHandling
        self.walletLifecycleService = walletLifecycleService
        self.fiatService = fiatService
        self.feeService = feeService
        self.moneroUriParser = moneroUriParser
        self.twoFactorAuthenticationService = twoFactorAuthenticationService
        self.localizer = localizer
    }
    
    public func start() {
        self.handleLegal()
    }

    private func startWallet() {
        if self.onboardingPending() {
            self.showOnboarding()
        } else if self.keychainLost() {
            self.fileHandling.purge(wallet: Constants.defaultWalletName)
            self.showOnboarding(keychainLost: true)
        } else {
            self.showLogin()
        }
    }

    private func handleLegal() {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let acceptedLegalVersion = self.propertyStore.legalAcceptedVersion
            if acceptedLegalVersion.elementsEqual(appVersion) {
                startWallet()
                return
            }
        }

        self.showLegal()
    }

    private func showLegal() {
        let storyboard = UIStoryboard(name: self.legalStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: legalSceneName) as! LegalVC
        vc.delegate = self
        vc.viewTitle = self.localizer.localized("legal.title")
        vc.acceptButtonTitle = self.localizer.localized("legal.button.accept")
        vc.declineButtonTitle = self.localizer.localized("legal.button.decline")

        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func onboardingPending() -> Bool {
        return !self.propertyStore.onboardingIsFinished
    }

    private func keychainLost() -> Bool {
        let documentPath = self.fileHandling.documentPath()
        let pathWithFileName = documentPath + Constants.defaultWalletName
                                
        let fileManager = FileManager.default
        Debug.print(s: "[AppCoordinator::keychainLost] WALLET LOCATION: \(pathWithFileName)")

        return !fileManager.fileExists(atPath: pathWithFileName) || self.secureStore.appPin == nil
      
    }
    
    private func showLogin() {
        let loginCoordinator = LoginCoordinator(navigationController: self.navigationController,
                                                moneroBag: self.moneroBag,
                                                secureStore: self.secureStore,
                                                fileHandling: self.fileHandling,
                                                walletLifecycleService: self.walletLifecycleService,
                                                twoFactorAuthenticationService: self.twoFactorAuthenticationService,
                                                watchCommunicationService: IocContainer.instance.watchCommunicationService,
                                                localizer: self.localizer)
        loginCoordinator.delegate = self
        loginCoordinator.start()
        
        self.add(childCoordinator: loginCoordinator)
    }
    
    private func showOnboarding(keychainLost: Bool = false) {
        let onboardingCoordinator = OnboardingCoordinator(navigationController: self.navigationController,
                                                          moneroBag: self.moneroBag,
                                                          onboardingService: self.onboardingService,
                                                          localizer: self.localizer)
        onboardingCoordinator.delegate = self
        onboardingCoordinator.start(keychainLost: keychainLost)
        
        self.add(childCoordinator: onboardingCoordinator)
    }

    private func showWallet() {
        let walletCoordinator = WalletCoordinator(navigationController: self.navigationController,
                                                  moneroBag: self.moneroBag,
                                                  walletLifecycleService: self.walletLifecycleService,
                                                  propertyStore: self.propertyStore,
                                                  secureStore: self.secureStore,
                                                  fiatService: self.fiatService,
                                                  feeService: self.feeService,
                                                  moneroUriParser: self.moneroUriParser,
                                                  localizer: self.localizer)
        walletCoordinator.delegate = self
        walletCoordinator.start()
        
        self.add(childCoordinator: walletCoordinator)
    }
}


extension AppCoordinator: LegalVCDelegate {

    public func legalVCAcceptButtonTouched(viewController: LegalVC) {
        self.navigationController.popViewController(animated: true)

        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.propertyStore.legalAcceptedVersion = appVersion
        }

        startWallet()
    }

    public func legalVCDeclineButtonTouched(viewController: LegalVC) {
        let alert = UIAlertController.init(title: "Scala iVault",
                                           message: self.localizer.localized("legal.decline.text"),
                                           preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: self.localizer.localized("global.ok"),
                                           style: .default,
                                           handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}


extension AppCoordinator: OnboardingCoordinatorDelegate  {

    public func onboardingCoordinatorLoginSucessful(onboardingCoordinator: OnboardingCoordinator) {
        self.navigationController.popToRootViewController(animated: false)
        self.remove(childCoordinator: onboardingCoordinator)
        self.showWallet()
    }
}


extension AppCoordinator: LoginCoordinatorDelegate {
    
    public func loginCoordinatorLoginSucessful(loginCoordinator: LoginCoordinator) {
        self.navigationController.popToRootViewController(animated: false)
        self.remove(childCoordinator: loginCoordinator)
        self.showWallet()
    }
}


extension AppCoordinator: WalletCoordinatorDelegate {
    
    public func walletCoordinatorWalletNuked(walletCoordinator: WalletCoordinator) {
        self.navigationController.popToRootViewController(animated: false)
        self.remove(childCoordinator: walletCoordinator)
        self.showOnboarding()
    }
}
