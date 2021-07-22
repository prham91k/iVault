//
//  NukeWalletCoordinator.swift
//  XWallet
//
//  Created by loj on 29.01.18.
//

import Foundation
import UIKit


public protocol NukeWalletCoordinatorDelegate: class {
    func nukeWalletCoordinatorCancelled(nukeWalletCoordinator: NukeWalletCoordinator)
    func nukeWalletCoordinatorWalletNuked(nukeWalletCoordinator: NukeWalletCoordinator)
}


public class NukeWalletCoordinator: Coordinator {
    
    private let pinStoryboardName = "Onboarding"
    private let pinSceneName = "PIN"
    
    private let navigationController: UINavigationController
    public var childCoordinators: [Coordinator] = []

    public weak var delegate: NukeWalletCoordinatorDelegate?
    
    private var secureStore: SecureStoreProtocol
    private var propertyStore: PropertyStoreProtocol
    private var wallet: WalletProtocol
    private var localizer: Localizable
    
    init(navigationController: UINavigationController,
         wallet: WalletProtocol,
         secureStore: SecureStoreProtocol,
         propertyStore: PropertyStoreProtocol,
         localizer: Localizable)
    {
        self.navigationController = navigationController
        self.wallet = wallet
        self.secureStore = secureStore
        self.propertyStore = propertyStore
        self.localizer = localizer
    }
    
    private lazy var storyboardPin: UIStoryboard = {
        let storyboard = UIStoryboard(name: self.pinStoryboardName, bundle: nil)
        return storyboard
    }()
    
    func start() {
        self.showPinViewController()
    }
    
    private func showPinViewController() {
        guard let appPin = self.secureStore.appPin else {
            return
        }
        
        let vc = storyboardPin.instantiateViewController(withIdentifier: pinSceneName) as! PinVC
        vc.delegate = self
        vc.viewTitle = self.localizer.localized("nukeWallet.pinView.title")
        vc.subTitle = self.localizer.localized("nukeWallet.pinView.subTitle")
        vc.backButtonTitle = self.localizer.localized("global.button.back")
        vc.nextButtonTitle = self.localizer.localized("nukeWallet.pinView.button.next")
        vc.instructionText = self.localizer.localized("nukeWallet.pinView.instruction")
        vc.pinMode = .confirmPin(withInitialPin: appPin)
        
        self.navigationController.pushViewController(vc, animated: true)
    }
}


extension NukeWalletCoordinator {
    
    private func nukeWallet() {
        self.wallet.lock()
        self.wallet.purge()

        self.secureStore.walletPassword = nil
        self.propertyStore.onboardingIsFinished = false
    }
}


extension NukeWalletCoordinator: PinVCDelegate {
    
    public func pinVCButtonNextTouched(pinEntered pin: String, viewController: PinVC) {
        self.nukeWallet()
        self.delegate?.nukeWalletCoordinatorWalletNuked(nukeWalletCoordinator: self)
    }
    
    public func pinVCButtonBackTouched() {
        self.delegate?.nukeWalletCoordinatorCancelled(nukeWalletCoordinator: self)
    }
}
