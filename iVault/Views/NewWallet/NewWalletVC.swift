//
//  ViewController.swift
//  XWallet
//
//  Created by loj on 26.07.17.
//

import UIKit


public protocol NewWalletVCDelegate: AnyObject {
    func newWalletVCDidSelectNewWallet(newWallet: NewWalletVC)
    func newWalletVCDidSelectRecoverWallet(newWallet: NewWalletVC)
}


public class NewWalletVC: UIViewController {
    
    @IBOutlet weak var newWalletButton: UIButton!
    @IBOutlet weak var recoverWalletButton: UIButton!
    @IBOutlet weak var keychainListLabel: UILabel!
    
    public weak var delegate: NewWalletVCDelegate?
    
    public var newWalletButtonTitle: String?
    public var recoverWalletButtonTitle: String?
    public var keychainLostLabelText: String?
    
    @IBAction func newWalletButtonTouched() {
        self.delegate?.newWalletVCDidSelectNewWallet(newWallet: self)
    }
    
    @IBAction func recoverWalletButtonTouched() {
        self.delegate?.newWalletVCDidSelectRecoverWallet(newWallet: self)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateView()
    }

    private func updateView() {
        if let newWalletButtonTitle = self.newWalletButtonTitle {
            self.newWalletButton.setTitle(newWalletButtonTitle, for: .normal)
        }
        if let recoverWalletButtonTitle = self.recoverWalletButtonTitle {
            self.recoverWalletButton.setTitle(recoverWalletButtonTitle, for: .normal)
        }

        self.keychainListLabel.text = self.keychainLostLabelText
    }
}
