//
//  ChangePinCoordinator.swift
//  XWallet
//
//  Created by loj on 28.01.18.
//

import Foundation
import UIKit


public protocol ChangePinCoordinatorDelegate: class {
    func changePinCoordinatorDone(changePinCoordinator: ChangePinCoordinator)
}


public class ChangePinCoordinator: Coordinator {
    
    private let pinStoryboardName = "Onboarding"
    private let pinSceneName = "PIN"
    
    private let navigationController: UINavigationController
    public var childCoordinators: [Coordinator] = []
    
    public weak var delegate: ChangePinCoordinatorDelegate?
    
    private var secureStore: SecureStoreProtocol
    private var newAppPin: String?
    private let localizer: Localizable
    
    init(navigationController: UINavigationController,
         secureStore: SecureStoreProtocol,
         localizer: Localizable)
    {
        self.navigationController = navigationController
        self.secureStore = secureStore
        self.localizer = localizer
    }
    
    private lazy var storyboardPin: UIStoryboard = {
        let storyboard = UIStoryboard(name: pinStoryboardName, bundle: nil)
        return storyboard
    }()
    
    private enum appPinState {
        case check
        case new
        case verify
        case verified
        case done
    }

    private var nextAppPinState = [
        appPinState.check: appPinState.new,
        appPinState.new: appPinState.verify,
        appPinState.verify: appPinState.verified,
        appPinState.verified: appPinState.done
    ]
    
    private var previousAppPinState = [
        appPinState.check: appPinState.done,
        appPinState.new: appPinState.done,
        appPinState.verify:appPinState.new,
        appPinState.verified:appPinState.done
    ]
    
    private var nextAppPinStateActionMapping = [
        appPinState.check: showCheckPinViewController,
        appPinState.new: showNewPinViewController,
        appPinState.verify: showVerifyPinViewController,
        appPinState.verified: changePin,
        appPinState.done: finish
    ]
    
    private var previousAppPinStateActionMapping = [
        appPinState.check: finish,
        appPinState.new: finish,
        appPinState.verify: backOneView,
        appPinState.verified: finish,
        appPinState.done: finish
    ]
    

    private var currentAppPinState: appPinState = .check
    
    func start() {
        self.performAction()
    }
    
    private func performAction() {
        if let action = self.nextAppPinStateActionMapping[self.currentAppPinState] {
            action(self)()
        }
    }
    
    private func showCheckPinViewController() {
        guard let currentAppPin = self.secureStore.appPin else {
            return
        }
        
        let vc = self.storyboardPin.instantiateViewController(withIdentifier: pinSceneName) as! PinVC
        vc.delegate = self
        vc.viewTitle = self.localizer.localized("changePin.checkPinView.title")
        vc.subTitle = self.localizer.localized("changePin.checkPinView.subTitle")
        vc.backButtonTitle = self.localizer.localized("global.button.back")
        vc.nextButtonTitle = self.localizer.localized("changePin.checkPinView.button.next")
        vc.instructionText = self.localizer.localized("changePin.checkPinView.instruction")
        vc.pinMode = .confirmPin(withInitialPin: currentAppPin)
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func showNewPinViewController() {
        let vc = self.storyboardPin.instantiateViewController(withIdentifier: pinSceneName) as! PinVC
        vc.delegate = self
        vc.viewTitle = self.localizer.localized("changePin.newPinView.title")
        vc.subTitle = self.localizer.localized("changePin.newPinView.subTitle")
        vc.backButtonTitle = self.localizer.localized("global.button.back")
        vc.nextButtonTitle = self.localizer.localized("changePin.newPinView.button.next")
        vc.instructionText = self.localizer.localized("changePin.newPinView.instruction")
        vc.pinMode = .initialPin
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func showVerifyPinViewController() {
        guard let newAppPin = self.newAppPin else {
            return
        }
        
        let vc = self.storyboardPin.instantiateViewController(withIdentifier: pinSceneName) as! PinVC
        vc.delegate = self
        vc.viewTitle = self.localizer.localized("changePin.verifyPinView.title")
        vc.subTitle = self.localizer.localized("changePin.verifyPinView.subTitle")
        vc.backButtonTitle = self.localizer.localized("global.button.back")
        vc.nextButtonTitle = self.localizer.localized("changePin.verifyPinView.button.next")
        vc.instructionText = self.localizer.localized("changePin.verifyPinView.instruction")
        vc.pinMode = .confirmPin(withInitialPin: newAppPin)
        
        self.navigationController.pushViewController(vc, animated: true)
    }

    private func changePin() {
        guard let newAppPin = self.newAppPin else {
            return
        }
        self.secureStore.appPin = newAppPin
        self.finish()
    }
    
    private func finish() {
        self.delegate?.changePinCoordinatorDone(changePinCoordinator: self)
    }
    
    private func backOneView() {
        self.navigationController.popViewController(animated: true)
    }
}


extension ChangePinCoordinator {
    
    private func transitionToNextPinState() {
        if let nextPinState = self.nextAppPinState[self.currentAppPinState] {
            self.currentAppPinState = nextPinState
            self.performAction()
        }
    }
    
    private func transitionToPreviousPinState() {
        if let previousPinState = self.previousAppPinState[self.currentAppPinState] {
            self.currentAppPinState = previousPinState
            self.performAction()
        }
    }
}


extension ChangePinCoordinator: PinVCDelegate {
    public func pinVCButtonNextTouched(pinEntered pin: String, viewController: PinVC) {
        self.newAppPin = pin
        self.transitionToNextPinState()
    }
    
    public func pinVCButtonBackTouched() {
        self.transitionToPreviousPinState()
    }
}
