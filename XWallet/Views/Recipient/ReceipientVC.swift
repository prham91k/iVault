//
//  ReceipientVC.swift
//  XWallet
//
//  Created by loj on 10.12.17.
//

import UIKit


protocol ReceipientVCDelegate: class {
    func receipientVCBackTouched()
    func receipientVCScanQRCodeTouched()
    func receipientVCPasteFromClipboardTouched(viewController: ReceipientVC)
    func receipientVCSendToDeveloperTouched(viewController: ReceipientVC)
}


class ReceipientVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var instructionTextLabel: UILabel!
    @IBOutlet weak var scanQRCodeButton: UIButton!
    @IBOutlet weak var pasteFromClipboardButton: UIButton!
    @IBOutlet weak var sendToDeveloperButton: UIButton!
    
    @IBAction func backButtonTouched() {
        self.delegate?.receipientVCBackTouched()
    }
    
    @IBAction func scanQRCodeButtonTouched() {
        self.delegate?.receipientVCScanQRCodeTouched()
    }
    
    @IBAction func pasteFromClipboardButtonTouched() {
        self.delegate?.receipientVCPasteFromClipboardTouched(viewController: self)
    }
    
    @IBAction func sendToDeveloperButtonTouched() {
        self.delegate?.receipientVCSendToDeveloperTouched(viewController: self)
    }
    
    public weak var delegate: ReceipientVCDelegate?

    public var viewTitle: String?
    public var backButtonTitle: String?
    public var subTitle: String?
    public var instructionText: String?
    public var scanQRCodeButtonTitle: String?
    public var pasteFromClipboardButtonTitle: String?
    public var sendToDeveloperButtonTitle: String?
    public var ok: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateView()
    }
    
    public func show(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: self.ok ?? "!!OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func updateView() {
        if let viewTitle = self.viewTitle {
            self.titleLabel.text = viewTitle
        }
        if let backButtonTitle = self.backButtonTitle {
            self.backButton.setTitle(backButtonTitle, for: .normal)
        }
        if let subTitle = self.subTitle {
            self.subTitleLabel.text = subTitle
        }
        if let instructionText = self.instructionText {
            self.instructionTextLabel.text = instructionText
        }
        if let scanQRCodeButtonTitle = self.scanQRCodeButtonTitle {
            self.scanQRCodeButton.setTitle(scanQRCodeButtonTitle, for: .normal)
        }
        if let pasteFromClipboardButtonTitle = self.pasteFromClipboardButtonTitle {
            self.pasteFromClipboardButton.setTitle(pasteFromClipboardButtonTitle, for: .normal)
        }
        if let sendToDeveloperButtonTitle = self.sendToDeveloperButtonTitle {
            self.sendToDeveloperButton.setTitle(sendToDeveloperButtonTitle, for: .normal)
        }
    }
}
