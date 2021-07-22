//
//  Configure2FACoordinator.swift
//  XWallet
//
//  Created by loj on 12.08.18.
//

import Foundation
import UIKit


public protocol Configure2FACoordinatorDelegate: AnyObject {
    func configure2FACoordinatorDone(configure2FACoordinator: Configure2FACoordinator)
}


public class Configure2FACoordinator: Coordinator {

    private let configure2FAStoryboardName = "Configure2FA"
    private let configure2FASceneName = "Configure2FA"

    private let onboardingStoryboardName = "Onboarding"
    private let pinSceneName = "PIN"

    private let navigationController: UINavigationController
    private var secureStore: SecureStoreProtocol
    private let watchCommunicationService: WatchCommunicationServiceProtocol
    private let localizer: Localizable

    public var childCoordinators: [Coordinator] = []
    
    public weak var delegate: Configure2FACoordinatorDelegate?

    private var configure2FAVC: Configure2FAVC?
    private var isInitialPin = true

    init(navigationController: UINavigationController,
         secureStore: SecureStoreProtocol,
         watchCommunicationService: WatchCommunicationServiceProtocol,
         localizer: Localizable)
    {
        self.navigationController = navigationController
        self.secureStore = secureStore
        self.watchCommunicationService = watchCommunicationService
        self.localizer = localizer
    }

    private lazy var configure2FAStoryboard: UIStoryboard = {
        let storyboard = UIStoryboard(name: configure2FAStoryboardName, bundle: nil)
        return storyboard
    }()

    private lazy var onboardingStoryboard: UIStoryboard = {
        let storyboard = UIStoryboard(name: onboardingStoryboardName, bundle: nil)
        return storyboard
    }()
    
    func start() {
        self.show2FASupportViewController()
    }

    private func show2FASupportViewController() {
        self.configure2FAVC = self.configure2FAStoryboard.instantiateViewController(withIdentifier: configure2FASceneName) as? Configure2FAVC
        if let vc = self.configure2FAVC {
            vc.viewModel = self.makeConfigure2FAViewModel()
            self.navigationController.pushViewController(vc, animated: true)
        }
    }

    private func reloadConfigure2FAVC() {
        if let vc = self.configure2FAVC {
            vc.viewModel = self.makeConfigure2FAViewModel()
            vc.refresh()
        }
    }

    private func getTwoFactorConfigurationState() -> TwoFactorConfigurationState {
        if let _ = self.secureStore.appleWatch2FAPassword {
            return .bound
        }
        return .unbound
    }

    private enum TwoFactorConfigurationState {
        case unbound
        case bound
    }

    private func makeConfigure2FAViewModel() -> Configure2FAViewModel {
        var viewModel = Configure2FAViewModel()
        viewModel.delegate = self
        viewModel.viewTitle = self.localizer.localized("configure2faView.title")
        viewModel.backButtonTitle = ""
        viewModel.enableAppleWatch2FACellTitle = self.localizer.localized("configure2faView.subTitle")

        switch self.getTwoFactorConfigurationState() {
        case .unbound:
            viewModel.enableAppleWatch2FACellButtonTitle = self.localizer.localized("configure2faView.unbound.button")
            viewModel.enableAppleWatch2FACellButtonColor = Colors.regularButtonColor
            viewModel.enableAppleWatch2FAInstructionText = self.localizer.localized("configure2faView.unbound.instruction")
        case .bound:
            viewModel.enableAppleWatch2FACellButtonTitle = self.localizer.localized("configure2faView.bound.button")
            viewModel.enableAppleWatch2FACellButtonColor = Colors.warningButtonColor
            viewModel.enableAppleWatch2FAInstructionText = self.localizer.localized("configure2faView.bound.instruction")
        }

        return viewModel
    }
}

extension Configure2FACoordinator: Configure2FAVCDelegate {
    
    public func configure2FAVCBackButtonTouched() {
        self.delegate?.configure2FACoordinatorDone(configure2FACoordinator: self)
    }
    
    public func configure2FAVCEnableAppleWatchTouched(viewController: UIViewController) {
        switch self.watchCommunicationService.getConnectivityState() {
        case .ok:
            self.askForPinCode()
        case .notSupported:
            self.showNotSupported(on: viewController)
        case .watchAppNotInstalled:
            self.showWatchAppNotInstalled(on: viewController)
        }
    }
    
    private func askForPinCode() {
        switch self.getTwoFactorConfigurationState() {
        case .unbound:
            self.setupNewPinCode()
        case .bound:
            self.askForExistingPinCode()
        }
    }

    private func setupNewPinCode() {
        let vc = self.onboardingStoryboard.instantiateViewController(withIdentifier: pinSceneName) as! PinVC
        vc.pinMode = .initialPin
        vc.progress = nil
        vc.delegate = self
        vc.viewTitle = self.localizer.localized("configure2fa.newPinView.title")
        vc.subTitle = self.localizer.localized("configure2fa.newPinView.subTitle")
        vc.instructionText = self.localizer.localized("configure2fa.newPinView.instruction")
        vc.backButtonTitle = self.localizer.localized("global.button.back")
        vc.nextButtonTitle = self.localizer.localized("configure2fa.newPinView.button.next")
        self.navigationController.pushViewController(vc, animated: true)
    }

    private func askForExistingPinCode() {
        guard let existingPinCode = self.secureStore.appleWatch2FAPassword else {
            return
        }

        let vc = self.onboardingStoryboard.instantiateViewController(withIdentifier: pinSceneName) as! PinVC
        vc.pinMode = .confirmPin(withInitialPin: existingPinCode)
        vc.progress = nil
        vc.delegate = self
        vc.viewTitle = self.localizer.localized("configure2fa.askForPinView.title")
        vc.subTitle = self.localizer.localized("configure2fa.askForPinView.subTitle")
        vc.instructionText = self.localizer.localized("configure2fa.askForPinView.instruction")
        vc.backButtonTitle = self.localizer.localized("global.button.next")
        vc.nextButtonTitle = self.localizer.localized("configure2fa.askForPinView.button.next")
        self.navigationController.pushViewController(vc, animated: true)
    }

    private func showNotSupported(on viewController: UIViewController) {
        let title = self.localizer.localized("configure2fa.notSupported.title")
        let message = self.localizer.localized("configure2fa.notSupported.message")
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: self.localizer.localized("global.ok"),
                                                style: .default,
                                                handler: nil))
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    private func showWatchAppNotInstalled(on viewController: UIViewController) {
        let title = self.localizer.localized("configure2fa.notInstalled.title")
        let message = self.localizer.localized("configure2fa.notInstalled.message")
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: self.localizer.localized("global.ok"),
                                                style: .default,
                                                handler: nil))
        viewController.present(alertController, animated: true, completion: nil)    }
}


extension Configure2FACoordinator: PinVCDelegate {

    public func pinVCButtonNextTouched(pinEntered pin: String, viewController: PinVC) {
        switch self.getTwoFactorConfigurationState() {
        case .unbound:
            self.bindAppleWatch2FA(with: pin)
        case .bound:
            self.unbindAppleWatch2FA()
        }
    }

    private func bindAppleWatch2FA(with pin: String) {
        if self.isInitialPin {
            self.showPinConfirmViewController(initialPin: pin)
        } else {
            self.secureStore.appleWatch2FAPassword = pin
            self.reloadConfigure2FAVC()
            if let configure2FAVC = self.configure2FAVC {
                self.navigationController.popToViewController(configure2FAVC, animated: true)
            }
        }
    }

    private func unbindAppleWatch2FA() {
        self.secureStore.appleWatch2FAPassword = nil
        self.reloadConfigure2FAVC()
        if let configure2FAVC = self.configure2FAVC {
            self.navigationController.popToViewController(configure2FAVC, animated: true)
        }
    }

    public func pinVCButtonBackTouched() {
        self.isInitialPin = true
        self.navigationController.popViewController(animated: true)
    }

    private func showPinConfirmViewController(initialPin: String) {
        self.isInitialPin = false

        let vc = self.onboardingStoryboard.instantiateViewController(withIdentifier: pinSceneName) as! PinVC
        vc.pinMode = .confirmPin(withInitialPin: initialPin)
        vc.progress = nil
        vc.delegate = self
        vc.viewTitle = self.localizer.localized("configure2fa.confirmPinView.title")
        vc.subTitle = self.localizer.localized("configure2fa.confirmPinView.subTitle")
        vc.instructionText = self.localizer.localized("configure2fa.confirmPinView.instruction")
        vc.backButtonTitle = self.localizer.localized("global.button.back")
        vc.nextButtonTitle = self.localizer.localized("configure2fa.confirmPinView.button.next")
        self.navigationController.pushViewController(vc, animated: false)
    }
}
