//
//  ReceiveVC.swift
//  XWallet
//
//  Created by loj on 25.11.17.
//

import UIKit


protocol ReceiveVCDelegate: class {
    func receiveVCBackTouched()
    func receiveVCCopyToClipboardTouched()
}


class ReceiveVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var qrcImageView: UIImageView!
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    
    @IBAction func backButtonTouched() {
        self.delegate?.receiveVCBackTouched()
    }
    
    @IBAction func copyToClipboardTouched() {
        self.delegate?.receiveVCCopyToClipboardTouched()
    }
    
    public weak var delegate: ReceiveVCDelegate?
    
    public var viewTitle: String?
    public var backButtonTitle: String?
    public var qrcImage: UIImage?
    public var walletAddress: String?
    public var copyButtonTitle: String?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateView()
    }

    private func updateView() {
        if let viewTitle = self.viewTitle {
            self.titleLabel.text = viewTitle
        }
        if let backButtonTitle = self.backButtonTitle {
            self.backButton.setTitle(backButtonTitle, for: .normal)
        }
        if let qrcImage = self.qrcImage {
            self.qrcImageView.image = qrcImage
        }
        if let walletAddress = self.walletAddress {
            self.walletAddressLabel.text = walletAddress
        }
        if let copyButtonTitle = self.copyButtonTitle {
            self.copyButton.setTitle(copyButtonTitle, for: .normal)
        }
    }
}
