//
//  LoginCoordinator.swift
//  XWallet
//
//  Created by loj on 15.11.17.
//

import Foundation
import UIKit


public protocol LoginCoordinatorDelegate: class {
    func loginCoordinatorLoginSucessful(loginCoordinator: LoginCoordinator)
}


public class LoginCoordinator: Coordinator {
    
    private let storyboardName = "Onboarding"
    private let pinSceneName = "PIN"
    private let appleWatch2FAStoryboardName = "2FA"
    private let appleWatch2FASceneName = "AppleWatch2FA"

    private var moneroBag: MoneroBagProtocol
    private var secureStore: SecureStoreProtocol
    private var fileHandling: FileHandlingProtocol
    private var walletLifecycleService: WalletLifecycleServiceProtocol
    private var twoFactorAuthenticationService: TwoFactorAuthenticationServiceProtocol
    private let watchCommunicationService: WatchCommunicationServiceProtocol
    private let localizer: Localizable

    private var authenticationRequestId: String?
    
    private let navigationController: UINavigationController
    public var childCoordinators: [Coordinator] = []

    weak var delegate: LoginCoordinatorDelegate?
    
    private lazy var storyboard: UIStoryboard = {
        let storyboard = UIStoryboard(name: self.storyboardName, bundle: nil)
        return storyboard
    }()
    
    private lazy var appleWatch2FAStoryboard: UIStoryboard = {
        let storyboard = UIStoryboard(name: self.appleWatch2FAStoryboardName, bundle: nil)
        return storyboard
    }()

    func start() {
        self.showAppPinViewController()
    }
    
    init(navigationController: UINavigationController,
         moneroBag: MoneroBagProtocol,
         secureStore: SecureStoreProtocol,
         fileHandling: FileHandlingProtocol,
         walletLifecycleService: WalletLifecycleServiceProtocol,
         twoFactorAuthenticationService: TwoFactorAuthenticationServiceProtocol,
         watchCommunicationService: WatchCommunicationServiceProtocol,
         localizer: Localizable)
    {
        self.navigationController = navigationController
        self.moneroBag = moneroBag
        self.secureStore = secureStore
        self.fileHandling = fileHandling
        self.walletLifecycleService = walletLifecycleService
        self.twoFactorAuthenticationService = twoFactorAuthenticationService
        self.watchCommunicationService = watchCommunicationService
        self.localizer = localizer
    }

    private enum PinKind {
        case unlockApp
        case appleWatch2FA
    }

    private var pinMode = PinKind.unlockApp
    
    private func showAppPinViewController() {
        guard let appPin = self.secureStore.appPin else {
            return
        }

        self.pinMode = .unlockApp
        
        let vc = self.storyboard.instantiateViewController(withIdentifier: pinSceneName) as! PinVC
        vc.pinMode = .confirmPin(withInitialPin: appPin)
        vc.pinAutoConfirm = true
        vc.progress = nil
        vc.delegate = self
        vc.viewTitle = self.localizer.localized("appPinView.title")
        vc.subTitle = self.localizer.localized("appPinView.subTitle")
        vc.instructionText = ""
        vc.backButtonTitle = nil
        vc.nextButtonTitle = ""
        self.navigationController.pushViewController(vc, animated: true)
    }

    private func showAppleWatch2FAViewController() {

        _ = "check if watch still paired"
        _ = "check if watch is reachable"

        let vc = self.appleWatch2FAStoryboard.instantiateViewController(withIdentifier: appleWatch2FASceneName) as! AppleWatch2FAVC
        vc.delegate = self
        vc.viewTitle = self.localizer.localized("appleWatch2faView.title")
        vc.subTitle = self.localizer.localized("appleWatch2faView.subTitle")
        vc.instructionText = self.localizer.localized("appleWatch2faView.instruction")
        vc.backButtonTitle = nil
        vc.nextButtonTitle = nil
        vc.requestAuthenticationButtonTitle = self.localizer.localized("appleWatch2faView.button.requestAuthentication")
        vc.requestAuthenticationButtonIsVisible = true
        vc.processingText = ""
        vc.skipAuthenticationButtonTitle = self.localizer.localized("appleWatch2faView.button.skipAuthentication")
        vc.skipAuthenticationButtonIsVisible = false
        self.navigationController.pushViewController(vc, animated: true)
    }

    private func showAppleWatchPinViewController() {
        guard let appleWatch2FAPin = self.secureStore.appleWatch2FAPassword else {
            return
        }

        self.pinMode = .appleWatch2FA

        let vc = self.storyboard.instantiateViewController(withIdentifier: pinSceneName) as! PinVC
        vc.pinMode = .confirmPin(withInitialPin: appleWatch2FAPin)
        vc.pinAutoConfirm = true
        vc.progress = nil
        vc.delegate = self
        vc.viewTitle = self.localizer.localized("appleWatchPinView.title")
        vc.subTitle = self.localizer.localized("appleWatchPinView.subTitle")
        vc.instructionText = ""
        vc.backButtonTitle = nil
        vc.nextButtonTitle = ""
        self.navigationController.pushViewController(vc, animated: true)
    }

    private func unlockWallet(viewController: ActivityIndicatorEnabled) {
        DispatchQueue.main.async {
            viewController.showActivityIndicator()
        }

        DispatchQueue.global(qos: .background).async {
            guard let walletPassword = self.secureStore.walletPassword,
                let wallet = self.walletLifecycleService.unlockWallet(withPassword: walletPassword) else
            {
                _ = "show message that unlock failed"
                return
            }
            self.moneroBag.wallet = wallet

            DispatchQueue.main.async {
                self.sendQRCToWatch(for: wallet.publicAddress)
                viewController.hideActivityIndicator()
                self.navigationController.popToRootViewController(animated: false )
                self.delegate?.loginCoordinatorLoginSucessful(loginCoordinator: self)
            }
        }
    }

    private func appleWatch2FAIsEnabled() -> Bool {
        if let _ = self.secureStore.appleWatch2FAPassword {
            return true
        }
        return false
    }

    private func sendQRCToWatch(for publicAddress: PublicWalletAddress?) {
        guard let address = publicAddress?.address else {
            return
        }
        guard let qrcImage = QRCGenerator.generate(from: address, scale: 8.0) else {
            return
        }
        self.watchCommunicationService.sendQRC(image: qrcImage)
    }
}


extension LoginCoordinator: PinVCDelegate {

    public func pinVCButtonNextTouched(pinEntered pin: String, viewController: PinVC) {
        switch self.pinMode {
        case .unlockApp:
            if self.appleWatch2FAIsEnabled() {
                self.showAppleWatch2FAViewController()
            } else {
                self.unlockWallet(viewController: viewController)
            }
        case .appleWatch2FA:
            self.unlockWallet(viewController: viewController)
        }
    }
    
    public func pinVCButtonBackTouched() {
        // perform no action as should not be called due to no back button visible
    }
}


extension LoginCoordinator: AppleWatch2FAVCDelegate {

    public func appleWatch2FAVCButtonBackTouched() {
        // perform no action as should not be called due to no back button visible
    }

    public func appleWatch2FAVCButtonRequestAuthenticationTouched(viewController: AppleWatch2FAVC) {
        viewController.requestAuthenticationButtonIsVisible = false
        viewController.skipAuthenticationButtonIsVisible = true
        viewController.processingText = self.localizer.localized("appleWatch2faView.message.processing")
        viewController.updateView()

        self.twoFactorAuthenticationService.authenticateOnWatch { (authenticationResult) in
            self.handle(authenticationResult: authenticationResult,
                        on: viewController)
        }
    }

    public func appleWatch2FAVCButtonSkipAuthenticationTouched(viewController: AppleWatch2FAVC) {
        self.showAppleWatchPinViewController()
    }

    private func handle(authenticationResult: TwoFactorAuthenticationResult,
                        on viewController: ActivityIndicatorEnabled & AppleWatch2FAVC)
    {
        switch authenticationResult {
        case .authenticated:
            self.unlockWallet(viewController: viewController)
        case .failed:
            self.show(message: self.localizer.localized("appleWatch2faView.message.failed"),
                      withTitle: self.localizer.localized("appleWatch2faView.message.title"),
                      on: viewController)
            self.enableAuthentication(on: viewController)
            break
        case .notAvailable:
            self.show(message: self.localizer.localized("appleWatch2faView.message.notAvailable"),
                      withTitle: self.localizer.localized("appleWatch2faView.message.title"),
                      on: viewController)
            break
        }
    }

    private func show(message: String,
                      withTitle title: String,
                      on viewController: UIViewController)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: self.localizer.localized("global.ok"), style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }

    private func enableAuthentication(on viewController: AppleWatch2FAVC) {
        viewController.requestAuthenticationButtonIsVisible = true
        viewController.skipAuthenticationButtonIsVisible = false
        viewController.processingText = ""
        viewController.updateView()
    }
}
