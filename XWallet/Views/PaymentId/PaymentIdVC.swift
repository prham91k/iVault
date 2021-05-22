//
//  PaymentIdVC.swift
//  XWallet
//
//  Created by loj on 10.12.17.
//

import UIKit


protocol PaymentIdVCDelegate: class {
    func paymentIdVCBackButtonTouched()
    func paymentIdVCNextButtonTouched(paymentId: String, viewController: PaymentIdVC)
    func paymentIdVCPasteFromClipboardButtonTouched(viewController: PaymentIdVC)
}


protocol ActivityIndicatorProtocol {
    func showActivityIndicator()
    func hideActivityIndicator()
}


class PaymentIdVC: UIViewController, ActivityIndicatorProtocol {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var instructionTextLabel: UILabel!
    @IBOutlet weak var paymentIdTextField: UITextField!
    @IBOutlet weak var pasteFromClipboardButton: UIButton!
    
    @IBAction func backButtonTouched() {
        self.delegate?.paymentIdVCBackButtonTouched()
    }
    
    @IBAction func nextButtonTouched() {
        self.delegate?.paymentIdVCNextButtonTouched(paymentId: self.paymentIdTextField.text ?? "",
                                                    viewController: self)
    }
    
    @IBAction func pasteFromClipboardButtonTouched() {
        self.delegate?.paymentIdVCPasteFromClipboardButtonTouched(viewController: self)
    }
    
    public weak var delegate: PaymentIdVCDelegate?

    public var viewTitle: String?
    public var backButtonTitle: String?
    public var nextButtonTitle: String?
    public var subTitle: String?
    public var instructionText: String?
    public var paymentIdText: String?
    public var paymentIdPlaceholderText: String?
    public var pasteFromClipboardButtonTitle: String?
    public var ok: String?

    fileprivate let activityIndicator = ActivityIndicatorHUD()

    public func refresh() {
        self.updateView()
    }

    public func show(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: self.ok ?? "!!OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateView()
    }
    
    public func showActivityIndicator() {
        self.activityIndicator.showAtCenter(ofParentView: self.view)
    }
    
    public func hideActivityIndicator() {
        self.activityIndicator.hide()
    }
    
    private func setup() {
//        self.drawPaymentIdUnderline()
    }
    
    private func drawPaymentIdUnderline() {
        let border = UIView()
        border.backgroundColor = UIColor.darkGray
        border.translatesAutoresizingMaskIntoConstraints = false
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.widthAnchor.constraint(equalTo: self.paymentIdTextField.widthAnchor).isActive = true
        border.bottomAnchor.constraint(equalTo: self.paymentIdTextField.bottomAnchor, constant: -1).isActive = true
        border.leftAnchor.constraint(equalTo: self.paymentIdTextField.leftAnchor).isActive = true

        self.paymentIdTextField.addSubview(border)
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
        if let subTitle = self.subTitle {
            self.subTitleLabel.text = subTitle
        }
        if let instructionText = self.instructionText {
            self.instructionTextLabel.text = instructionText
        }
        if let paymentIdPlaceholderText = self.paymentIdPlaceholderText {
            self.paymentIdTextField.placeholder = paymentIdPlaceholderText
        }
        if let paymentIdText = self.paymentIdText {
            self.paymentIdTextField.text = paymentIdText
        }
        if let pasteFromClipboardButtonTitle = self.pasteFromClipboardButtonTitle {
            self.pasteFromClipboardButton.setTitle(pasteFromClipboardButtonTitle, for: .normal)
        }
    }
}
