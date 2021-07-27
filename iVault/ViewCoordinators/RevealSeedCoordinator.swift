//
//  RevealSeedCoordinator.swift
//  XWallet
//
//  Created by loj on 26.01.18.
//

import Foundation
import UIKit


public protocol RevealSeedCoordinatorDelegate: class {
    func revealSeedCoordinatorDone(revealSeedCoordinator: RevealSeedCoordinator)
}


public class RevealSeedCoordinator: Coordinator {
    
    private let pinStoryboardName = "Onboarding"
    private let pinSceneName = "PIN"
    private let seedStoryboardName = "Onboarding"
    private let seedSceneName = "Seed"

    private var secureStore: SecureStoreProtocol
    private var wallet: WalletProtocol
    private var localizer: Localizable
    
    private let navigationController: UINavigationController
    public var childCoordinators: [Coordinator] = []

    public weak var delegate: RevealSeedCoordinatorDelegate?

    private lazy var storyboardPin: UIStoryboard = {
        let storyboard = UIStoryboard(name: pinStoryboardName, bundle: nil)
        return storyboard
    }()
    
    private lazy var storyboardSeed: UIStoryboard = {
        let storyboard = UIStoryboard(name: seedStoryboardName, bundle: nil)
        return storyboard
    }()
    
    init(navigationController: UINavigationController,
         secureStore: SecureStoreProtocol,
         wallet: WalletProtocol,
         localizer: Localizable)
    {
        self.navigationController = navigationController
        self.secureStore = secureStore
        self.wallet = wallet
        self.localizer = localizer
    }

    func start() {
        self.showPinViewController()
    }
    
    private func showPinViewController() {
        guard let appPin = self.secureStore.appPin else {
            return
        }
        
        let vc = self.storyboardPin.instantiateViewController(withIdentifier: pinSceneName) as! PinVC
        vc.delegate = self
        vc.pinMode = .confirmPin(withInitialPin: appPin)
        vc.pinAutoConfirm = true
        vc.progress = nil
        vc.viewTitle = self.localizer.localized("revealSeed.pinView.title")
        vc.subTitle = self.localizer.localized("revealSeed.pinView.subTitle")
        vc.instructionText = ""
        vc.backButtonTitle = ""
        vc.nextButtonTitle = ""
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func showSeedViewController() {
        let vc = self.storyboardSeed.instantiateViewController(withIdentifier: seedSceneName) as! SeedVC
        vc.delegate = self
        vc.seed = self.wallet.seed
        vc.progress = nil
        vc.backButtonTitle = ""
        vc.nextButtonTitle = ""
        vc.viewTitle = self.localizer.localized("revealSeed.seedView.title")
        vc.subTitle = ""
        vc.instructionText = ""
        self.navigationController.pushViewController(vc, animated: true)
    }
}


extension RevealSeedCoordinator: PinVCDelegate {
    
    public func pinVCButtonNextTouched(pinEntered pin: String, viewController: PinVC) {
        self.showSeedViewController()
    }
    
    public func pinVCButtonBackTouched() {
        self.delegate?.revealSeedCoordinatorDone(revealSeedCoordinator: self)
    }
}


extension RevealSeedCoordinator: SeedVCDelegeta {
    
    func seedVCButtonNextTouched() {
    }
    
    func seedVCButtonBackTouched() {
        self.delegate?.revealSeedCoordinatorDone(revealSeedCoordinator: self)
    }
}
