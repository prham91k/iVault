//
//  AmountVC.swift
//  XWallet
//
//  Created by loj on 10.12.17.
//

import UIKit


protocol AmountVCDelegate: class {
    func amountVCBackTouched()
    func amountVCNextButtonTouched(formattedAmount: String, viewController: AmountVC)
    func amountVCTotalAmountButtonTouched(viewController: AmountVC)
    func amountVCAmountValueChanged(amount: Double?, viewController: AmountVC)
}


class AmountVC: UIViewController, ActivityIndicatorProtocol {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var amountOtherLabel: UILabel!
    @IBOutlet weak var totalAmountAvailableButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackViewBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceValueLabel: UILabel!
    @IBOutlet weak var estimatedFeeLabel: UILabel!
    @IBOutlet weak var estimatedFeeValueLabel: UILabel!
    
    @IBAction func backButtonTouched() {
        self.delegate?.amountVCBackTouched()
    }
    
    @IBAction func nextButtonTouched() {
        let selectedAmount = self.amountTextField.text ?? "0"
        self.delegate?.amountVCNextButtonTouched(formattedAmount: selectedAmount, viewController: self)
    }
    
    @IBAction func totalAmountButtonTouched() {
        self.delegate?.amountVCTotalAmountButtonTouched(viewController: self)
    }
    
    public weak var delegate: AmountVCDelegate?
    
    public var viewTitle: String?
    public var backButtonTitle: String?
    public var nextButtonTitle: String?
    public var currencyText: String?
    public var amountText: String?
    public var amountOtherText: String?
    public var totalAmountAvailableButtonTitle: String?
    public var balanceTitle: String?
    public var balanceValueText: String?
    public var estimatedFeeTitle: String?
    public var estimatedFeeValueText: String?

    fileprivate let activityIndicator = ActivityIndicatorHUD()

    public func refresh() {
        self.updateView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.updateView()
        self.registerNotificationHandlers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.deregisterNotificationHandlers()
    }
    
    public func showActivityIndicator() {
        self.activityIndicator.showAtCenter(ofParentView: self.view)
    }
    
    public func hideActivityIndicator() {
        self.activityIndicator.hide()
    }
    
    public func showFiatValue(_ fiatValue: String, forCurrency currency: String) {
        self.amountOtherLabel.text = "\(currency) \(fiatValue)"
    }
    
    public func nextAllowed() {
        self.nextButton.isEnabled = true
    }
    
    public func nextNotAllowed() {
        self.nextButton.isEnabled = false
    }

    private func setup() {
        self.amountTextField.delegate = self
    }

    private func registerNotificationHandlers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func deregisterNotificationHandlers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func updateView() {
        if let viewTitle = self.viewTitle {
            self.titleLabel.text = viewTitle
        }
        if let backButtonTitle = self.backButtonTitle {
            self.backButton.setTitle(backButtonTitle, for: .normal)
        }
        if let nextButtonTitle = self.nextButtonTitle {
            self.nextButton.setTitle(nextButtonTitle, for: .normal)
        }
        if let currencyText = self.currencyText {
            self.currencyLabel.text = currencyText
        }
        if let amountText = self.amountText {
            self.amountTextField.text = amountText
        }
        if let amountOtherText = self.amountOtherText {
            self.amountOtherLabel.text = amountOtherText
        }
        if let totalAmountAvailableButtonTitle = self.totalAmountAvailableButtonTitle {
            self.totalAmountAvailableButton.setTitle(totalAmountAvailableButtonTitle, for: .normal)
        }
        if let balanceTitle = self.balanceTitle {
            self.balanceLabel.text = balanceTitle
        }
        if let balanceValueText = self.balanceValueText {
            self.balanceValueLabel.text = balanceValueText
        }
        if let estimatedFeeLabel = self.estimatedFeeTitle {
            self.estimatedFeeLabel.text = estimatedFeeLabel
        }
        if let estimatedFeeValueText = self.estimatedFeeValueText {
            self .estimatedFeeValueLabel.text = estimatedFeeValueText
        }
        
        self.amountTextField.becomeFirstResponder()
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        let extraBottomSpace = CGFloat(20.0)

        UIView.animate(withDuration: 0.1) {
            self.stackViewBottomLayoutConstraint.constant = keyboardHeight + extraBottomSpace
            self.stackView.frame.size.height -= keyboardHeight
            self.stackView.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        UIView.animate(withDuration: 0.1) {
            self.stackViewBottomLayoutConstraint.constant = 0
            self.stackView.frame.size.height += keyboardHeight
            self.stackView.layoutIfNeeded()
        }
    }
}


extension AmountVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let swiftRange = Range(range, in: textField.text!)!
        var modified = textField.text!
        modified.replaceSubrange(swiftRange, with: string)

        if let prettyPrinted = modified.prettyPrintDouble() {
            textField.text = prettyPrinted
        }

        if let amountValue = textField.text {
            self.delegate?.amountVCAmountValueChanged(amount: amountValue.toDouble(), viewController: self)
        }
        
        return false
    }
}
