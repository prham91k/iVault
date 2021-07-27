//
//  TextFieldCellWithLabel.swift
//  XWallet
//
//  Created by loj on 02.02.18.
//

import UIKit

class TextFieldCellWithLabel: UITableViewCell {

    @IBOutlet weak var textTextField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    public var textValue: String?
    public var textValueIsPassword: Bool?
    public var descriptionValue: String?
    
    public var onClose: (() -> Void)?
    
    public func redraw() {
        self.showData()
    }
    
    private func showData() {
        if let textValue = self.textValue {
            self.textTextField.text = textValue
        }
        if let textValueIsPassword = self.textValueIsPassword {
            self.textTextField.isSecureTextEntry = textValueIsPassword
        }
        if let descriptionValue = self.descriptionValue {
            self.descriptionLabel.text = descriptionValue
        }
    }
    
    override func layoutSubviews() {
        self.textTextField.delegate = self
    }
}


extension TextFieldCellWithLabel: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.textValue = textField.text
        self.onClose?()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
