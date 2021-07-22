//
//  NewWalletCoordinator.swift
//  XWallet
//
//  Created by loj on 24.10.17.
//

import Foundation
import UIKit


public protocol OnboardingCoordinatorDelegate: class {
    func onboardingCoordinatorLoginSucessful(onboardingCoordinator: OnboardingCoordinator)
}


public class OnboardingCoordinator: Coordinator {
    
    private let storyboardName = "Onboarding"
    private let newWalletSceneName = "NewWallet"
    private let seedSceneName = "Seed"
    private let pinSceneName = "PIN"
    private let recoverSceneName = "Recover"

    private var moneroBag: MoneroBagProtocol
    private var onboardingService: OnboardingServiceProtocol
    private var localizer: Localizable

    private let navigationController: UINavigationController
    public var childCoordinators: [Coordinator] = []

    weak var delegate: OnboardingCoordinatorDelegate?

    private enum NewWalletMode {
        case fromScratch
        case recoverFromSeed
    }
    private var newWalletMode: NewWalletMode = .fromScratch
    
    private var isInitialPin = true
    
    private lazy var storyboard: UIStoryboard = {
        let storyboard = UIStoryboard(name: self.storyboardName, bundle: nil)
        return storyboard
    }()

    func start(keychainLost: Bool) {
        self.showNewWalletView(keychainLost: keychainLost)
    }

    init(navigationController: UINavigationController,
         moneroBag: MoneroBagProtocol,
         onboardingService: OnboardingServiceProtocol,
         localizer: Localizable)
    {
        self.navigationController = navigationController
        self.moneroBag = moneroBag
        self.onboardingService = onboardingService
        self.localizer = localizer
    }
    
    private func showNewWalletView(keychainLost: Bool) {
        let vc = self.storyboard.instantiateViewController(withIdentifier: self.newWalletSceneName) as! NewWalletVC
        vc.delegate = self
        vc.newWalletButtonTitle = self.localizer.localized("newWalletView.button.new")
        vc.recoverWalletButtonTitle = self.localizer.localized("newWalletView.button.recover")
        vc.keychainLostLabelText = keychainLost ? self.localizer.localized("newWalletView.keychainLost") : nil
        self.navigationController.pushViewController(vc, animated: true)
    }
}


extension OnboardingCoordinator: NewWalletVCDelegate {
    
    public func newWalletVCDidSelectNewWallet(newWallet: NewWalletVC) {
        self.newWalletMode = .fromScratch
        self.showPinViewController()
    }
    
    public func newWalletVCDidSelectRecoverWallet(newWallet: NewWalletVC) {
        self.newWalletMode = .recoverFromSeed
        self.showPinViewController()
    }
    
    private func showPinViewController() {
        let vc = self.storyboard.instantiateViewController(withIdentifier: pinSceneName) as! PinVC
        vc.pinMode = .initialPin
        vc.progress = 0.333
        vc.delegate = self
        vc.viewTitle = self.localizer.localized("pinView.title")
        vc.subTitle = self.localizer.localized("pinView.subTitle")
        vc.instructionText = self.localizer.localized("pinView.instruction")
        vc.backButtonTitle = self.localizer.localized("global.button.back")
        vc.nextButtonTitle = self.localizer.localized("pinView.button.next")
        self.navigationController.pushViewController(vc, animated: true)
    }
    
}


extension OnboardingCoordinator: PinVCDelegate {
    
    public func pinVCButtonNextTouched(pinEntered appPin: String, viewController: PinVC) {
        if self.isInitialPin {
            self.showPinConfirmViewController(initialPin: appPin)
        } else {
            self.onboardingService.setAppPin(appPin)
            self.onboardingService.setWalletName(Constants.defaultWalletName)
            
            switch self.newWalletMode {
            case .fromScratch:
                self.showSeedViewController()
            case .recoverFromSeed:
                self.showRecoverySeedViewController()
            }
        }
    }
    
    public func pinVCButtonBackTouched() {
        self.isInitialPin = true
        self.navigationController.popViewController(animated: true)
    }
    
    private func showPinConfirmViewController(initialPin: String) {
        self.isInitialPin = false
        
        let vc = self.storyboard.instantiateViewController(withIdentifier: pinSceneName) as! PinVC
        vc.pinMode = .confirmPin(withInitialPin: initialPin)
        vc.progress = 0.666
        vc.delegate = self
        vc.viewTitle = self.localizer.localized("pinConfirmView.title")
        vc.subTitle = self.localizer.localized("pinConfirmView.subTitle")
        vc.instructionText = self.localizer.localized("pinConfirmView.instruction")
        vc.backButtonTitle = self.localizer.localized("global.button.back")
        vc.nextButtonTitle = self.localizer.localized("pinConfirmView.button.next")
        self.navigationController.pushViewController(vc, animated: false)
    }
    
    private func showSeedViewController() {
        guard let wallet = try? self.onboardingService.createNewWallet() else {
            // TODO: (loj) show popup with error message
            return
        }
        self.moneroBag.wallet = wallet
        
        let vc = self.storyboard.instantiateViewController(withIdentifier: self.seedSceneName) as! SeedVC
        vc.delegate = self
        vc.seed = wallet.seed
        vc.progress = 1.0
        vc.backButtonTitle = self.localizer.localized("global.button.back")
        vc.nextButtonTitle = self.localizer.localized("seedView.button.next")
        vc.viewTitle = self.localizer.localized("seedView.title")
        vc.subTitle = self.localizer.localized("seedView.subTitle")
        vc.instructionText = self.localizer.localized("seedView.instruction")
        self.navigationController.pushViewController(vc, animated: false)
    }
    
    private func showRecoverySeedViewController() {
        let vc = self.storyboard.instantiateViewController(withIdentifier: self.recoverSceneName) as! RecoverSeedVC
        vc.delegate = self
        vc.progress = 1.0
        vc.backButtonTitle = self.localizer.localized("global.button.back")
        vc.nextButtonTitle = self.localizer.localized("recoverySeedView.button.next")
        vc.subTitle = self.localizer.localized("recoverySeedView.subTitle")
        vc.instructionText = self.localizer.localized("recoverySeedView.instruction")
        self.navigationController.pushViewController(vc, animated: false)
    }
    
}


extension OnboardingCoordinator: SeedVCDelegeta {
    
    func seedVCButtonNextTouched() {
        self.delegate?.onboardingCoordinatorLoginSucessful(onboardingCoordinator: self)
    }
    
    func seedVCButtonBackTouched() {
        self.onboardingService.purgeWallet()
        self.navigationController.popViewController(animated: true)
    }
    
}


extension OnboardingCoordinator: RecoverSeedVCDelegeta {

    func recoverSeedVCButtonNextTouched(seed: Seed) {
        self.onboardingService.setSeed(seed)
        
        guard let wallet = try? self.onboardingService.recoverWallet() else {
            // TODO: (loj) show popup with error message
            return
        }
        self.moneroBag.wallet = wallet
        self.delegate?.onboardingCoordinatorLoginSucessful(onboardingCoordinator: self)
    }
    
    func recoverSeedVCButtonBackTouched() {
        self.navigationController.popViewController(animated: true)
    }

}
