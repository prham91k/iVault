//
//  Configure2FAViewModel.swift
//  XWallet
//
//  Created by loj on 19.08.18.
//

import Foundation
import UIKit


public protocol Configure2FAVCDelegate: class {
    func configure2FAVCBackButtonTouched()
    func configure2FAVCEnableAppleWatchTouched(viewController: UIViewController)
}


struct Configure2FAViewModel {

    public weak var delegate: Configure2FAVCDelegate?

    public var viewTitle: String?
    public var backButtonTitle: String?

    public var enableAppleWatch2FACellTitle: String?
    public var enableAppleWatch2FACellButtonTitle: String?
    public var enableAppleWatch2FAInstructionText: String?

    public var enableAppleWatch2FACellButtonColor: ButtonColor = Colors.regularButtonColor
}
