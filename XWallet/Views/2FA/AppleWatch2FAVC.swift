//
//  AppleWatch2FAVC.swift
//  XWallet
//
//  Created by loj on 30.07.18.
//

import UIKit


public protocol AppleWatch2FAVCDelegate: class {
    func appleWatch2FAVCButtonBackTouched()
    func appleWatch2FAVCButtonRequestAuthenticationTouched(viewController: AppleWatch2FAVC)
    func appleWatch2FAVCButtonSkipAuthenticationTouched(viewController: AppleWatch2FAVC)
}


public class AppleWatch2FAVC: UIViewController, ActivityIndicatorEnabled {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var instructionTextLabel: UILabel!
    @IBOutlet weak var requestAuthenticationButton: UIButton!
    @IBOutlet weak var processingTextLabel: UILabel!
    @IBOutlet weak var skipAuthenticationButton: UIButton!

    @IBAction func backButtonTouched() {
        self.delegate?.appleWatch2FAVCButtonBackTouched()
    }

    @IBAction func requestAuthenticationButtonTouched() {
        self.delegate?.appleWatch2FAVCButtonRequestAuthenticationTouched(viewController: self)
    }

    @IBAction func skipAuthenticationButtonTouched() {
        self.delegate?.appleWatch2FAVCButtonSkipAuthenticationTouched(viewController: self)
    }

    public weak var delegate: AppleWatch2FAVCDelegate?

    public var viewTitle: String?
    public var subTitle: String?
    public var instructionText: String?
    public var backButtonTitle: String?
    public var nextButtonTitle: String?
    public var nextButtonIsEnabled: Bool?
    public var requestAuthenticationButtonTitle: String?
    public var requestAuthenticationButtonIsVisible: Bool?
    public var processingText: String?
    public var skipAuthenticationButtonTitle: String?
    public var skipAuthenticationButtonIsVisible: Bool?

    public var activityIndicator: ActivityIndicatorHUD? = ActivityIndicatorHUD()

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.updateView()
    }

    public func updateView() {
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

        if let requestAuthenticationButtonTitle = self.requestAuthenticationButtonTitle {
            self.requestAuthenticationButton.setTitle(requestAuthenticationButtonTitle, for: .normal)
        }
        self.requestAuthenticationButton.isHidden = !(self.requestAuthenticationButtonIsVisible ?? false)

        if let otherText = self.processingText {
            self.processingTextLabel.text = otherText
        }

        if let skipAuthenticationButtonTitle = self.skipAuthenticationButtonTitle {
            self.skipAuthenticationButton.setTitle(skipAuthenticationButtonTitle, for: .normal)
        }
        self.skipAuthenticationButton.isHidden = !(self.skipAuthenticationButtonIsVisible ?? false)
    }
}
