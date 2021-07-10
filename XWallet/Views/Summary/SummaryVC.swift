//
//  ConfirmVC.swift
//  XWallet
//
//  Created by loj on 10.12.17.
//

import UIKit


protocol SummaryVCDelegate: AnyObject {
    func summaryVCBackButtonTouched()
    func summaryVCConfirmButtonTouched()
}


class SummaryVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressValueLabel: UILabel!
    @IBOutlet weak var paymentIdLabel: UILabel!
    @IBOutlet weak var paymentIdValueLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var subtotalValueLabel: UILabel!
    @IBOutlet weak var networkFeeLabel: UILabel!
    @IBOutlet weak var networkFeeValueLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var balanaceInsufficientLabel: UILabel!
    
    @IBAction func backButtonTouched() {
        self.delegate?.summaryVCBackButtonTouched()
    }
    
    @IBAction func confirmButtonTouched() {
        self.delegate?.summaryVCConfirmButtonTouched()
    }
    
    public weak var delegate: SummaryVCDelegate?
    
    public var viewTitle: String?
    public var backButtonTitle: String?
    public var subTitle: String?
    public var addressText: String?
    public var addressValueText: String?
    public var paymentIdText: String?
    public var paymentIdValueText: String?
    public var subtotalText: String?
    public var subtotalValueText: String?
    public var networkFeeText: String?
    public var networkFeeValueText: String?
    public var totalText: String?
    public var totalValueText: String?
    public var confirmButtonTitle: String?
    public var balanceIsSufficient: Bool = true
    public var balanaceInsufficientText: String?
    
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
        if let subTitle = self.subTitle {
            self.subTitleLabel.text = subTitle
        }
        if let addressText = self.addressText {
            self.addressLabel.text = addressText
            self.addressLabel.isHidden = false
        } else {
            self.addressLabel.isHidden = true
        }
        if let addressValueText = self.addressValueText {
            self.addressValueLabel.text = addressValueText
            self.addressValueLabel.isHidden = false
        } else {
            self.addressValueLabel.isHidden = true
        }
        if let paymentIdText = self.paymentIdText {
            self.paymentIdLabel.text = paymentIdText
            self.paymentIdLabel.isHidden = false
        } else {
            self.paymentIdLabel.isHidden = true
        }
        if let paymentIdValueText = self.paymentIdValueText {
            self.paymentIdValueLabel.text = paymentIdValueText
            self.paymentIdValueLabel.isHidden = false
        } else {
            self.paymentIdValueLabel.isHidden = true
        }
        if let subtotalText = self.subtotalText {
            self.subtotalLabel.text = subtotalText
        }
        subtotalValueLabel.text = self.subtotalValueText ?? ""
        if let networkFeeText = self.networkFeeText {
            self.networkFeeLabel.text = networkFeeText
        }
        networkFeeValueLabel.text = self.networkFeeValueText ?? ""
        if let totalText = self.totalText {
            self.totalLabel.text = totalText
        }
        totalValueLabel.text = self.totalValueText ?? ""

        if let confirmButtonTitle = self.confirmButtonTitle {
            self.confirmButton.setTitle(confirmButtonTitle, for: .normal)
        }
        if let balanceInsufficientText = self.balanaceInsufficientText {
            self.balanaceInsufficientLabel.text = "\n\(balanceInsufficientText)\n"
        }
        
        self.checkBalance()
    }
    
    private func checkBalance() {
        if self.balanceIsSufficient {
            self.showSufficientBalance()
        } else {
            self.showInsufficientBalance()
        }
    }
    
    private func showSufficientBalance() {
        self.networkFeeLabel.isHidden = false
        self.networkFeeValueLabel.isHidden = false
        
        self.totalLabel.isHidden = false
        self.totalValueLabel.isHidden = false
        
        self.balanaceInsufficientLabel.isHidden = true
        self.confirmButton.isHidden = false
    }
    
    private func showInsufficientBalance() {
        self.networkFeeLabel.isHidden = true
        self.networkFeeValueLabel.isHidden = true
        
        self.totalLabel.isHidden = true
        self.totalValueLabel.isHidden = true
        
        self.balanaceInsufficientLabel.isHidden = false
        self.confirmButton.isHidden = true
    }
}
