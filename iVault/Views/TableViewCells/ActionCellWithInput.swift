//
//  ActionCellWithInput.swift
//  iVault
//
//  Created by Azizul Hakimi Mohd Yussuf Izzudin on 27/04/2023.
//  Copyright © 2023 loj. All rights reserved.
//

import UIKit

class ActionCellWithInput: UITableViewCell {

    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var cellInputField: UITextField!
    @IBOutlet weak var button: UIButton!
    
    @IBAction func buttonTouched() {
        if let handler = self.buttonTouchedHandler {
            handler()
        }
    }
    
    public var cellTitle: String?
    public var cellInput: String?
    public var buttonTitle: String?
    public var buttonTouchedHandler: (() -> Void)?
    
    public func redraw() {
        self.showData()
    }
    
    private func showData() {
        if let cellTitle = self.cellTitle {
            self.cellTitleLabel.text = cellTitle
        }
        if let cellInput = self.cellInput {
            self.cellInputField.text = cellInput
        }
        if let buttonTitle = self.buttonTitle {
            self.button.setTitle(buttonTitle, for: .normal)
        }
    }
}
