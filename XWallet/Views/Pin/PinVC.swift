//
//  PinVC.swift
//  XWallet
//
//  Created by loj on 15.10.17.
//

import UIKit


public protocol PinVCDelegate: AnyObject {
    func pinVCButtonNextTouched(pinEntered pin: String, viewController: PinVC)
    func pinVCButtonBackTouched()
}


@IBDesignable
public class PinVC: UIViewController, ActivityIndicatorEnabled {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var instructionTextLabel: UILabel!
    @IBOutlet weak var pinDotView: PinDotView!

    @IBAction func backButtonTouched() {
        self.delegate?.pinVCButtonBackTouched()
    }
    
    @IBAction func nextButtonTouched() {
        self.delegate?.pinVCButtonNextTouched(pinEntered: self.pinCode, viewController: self)
    }
    
    public weak var delegate: PinVCDelegate?
    
    public var viewTitle: String?
    public var subTitle: String?
    public var instructionText: String?
    public var backButtonTitle: String?
    public var nextButtonTitle: String?
    public var progress: Float?
    
    public enum PinEntryMode {
        case initialPin
        case confirmPin(withInitialPin: String)
    }
    public var pinMode: PinEntryMode = .initialPin
    public var pinAutoConfirm: Bool = false
    
    fileprivate var pinCode: String = ""
    public var activityIndicator: ActivityIndicatorHUD? = ActivityIndicatorHUD()
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.setup()
        self.updateView()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.becomeFirstResponder()
    }
    
    private func setup() {
        self.pinDotView.totalDotCount = Constants.pinCodeLength
        self.pinDotView.inputDotCount = 0
        self.pinDotView.fillColor = .label
        
        self.nextButton.isEnabled = false
    }
    
    private func updateView() {
        if let viewTitle = self.viewTitle {
            self.titleLabel.text = viewTitle
        }
        if let subTitle = self.subTitle {
            self.subTitleLabel.text = subTitle
        }
        if let instructionText = self.instructionText {
            self.instructionTextLabel.text = instructionText
        }
        if let backButtonTitle = self.backButtonTitle {
            self.backButton.isHidden = false
            self.backButton.setTitle(backButtonTitle, for: .normal)
        } else {
            self.backButton.isHidden = true
        }
        if let nextButtonTitle = self.nextButtonTitle {
            self.nextButton.setTitle(nextButtonTitle, for: .normal)
        }
        if let progress = self.progress {
            self.progressView.isHidden = false
            self.progressView.progress = progress
        } else {
            self.progressView.isHidden = true
        }
    }

}


extension PinVC : UIKeyInput {
    
    override public var canBecomeFirstResponder: Bool {
        return true
    }
    
    public var hasText: Bool {
        return self.pinCode.count > 0
    }
    
    public func insertText(_ text: String) {
        if self.pinCode.count < Constants.pinCodeLength {
            self.pinCode.append(text)
            self.pinDotView.inputDotCount += 1
        }
        
        if self.pinCode.count < Constants.pinCodeLength {
            return
        }
        
        switch self.pinMode {
        case .initialPin:
            self.initialPinCompleted()
        case let .confirmPin(initialPin):
            self.confirmationPinCompleted(compareWith: initialPin)
        }
    }
    
    private func initialPinCompleted() {
        self.nextButton.isEnabled = true
    }
    
    private func confirmationPinCompleted(compareWith initialPin: String) {
        if initialPin == self.pinCode {
            if self.pinAutoConfirm {
                self.nextButtonTouched()
            } else {
                self.nextButton.isEnabled = true
            }
            return
        }
        
        self.pinDotView.shakeAnimationWithCompletion {}
        self.pinCode.removeAll()
        self.pinDotView.inputDotCount = 0
        self.nextButton.isEnabled = false

    }
    
    public func deleteBackward() {
        if self.hasText {
            self.pinCode = String(self.pinCode.dropLast())
            self.pinDotView.inputDotCount -= 1
        }
        
        self.nextButton.isEnabled = false
    }
}


extension PinVC: UITextInputTraits {
    
    public var keyboardType: UIKeyboardType {
        get { return .numberPad }
        set { }
    }
    
}
