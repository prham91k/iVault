//
//  Enable2FACell.swift
//  XWallet
//
//  Created by loj on 19.08.18.
//

import UIKit

class Enable2FACell: UITableViewCell {

    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var instructionTextLabel: UILabel!

    @IBAction func buttonTouched() {
        if let handler = self.buttonTouchedHandler {
            handler()
        }
    }

    public var cellTitle: String?
    public var buttonTitle: String?
    public var instructionText: String?
    public var buttonTouchedHandler: (() -> Void)?

    public func redraw() {
        self.showData()
    }

    private func showData() {
        if let cellTitle = self.cellTitle {
            self.cellTitleLabel.text = cellTitle
        }
        if let buttonTitle = self.buttonTitle {
            self.button.setTitle(buttonTitle, for: .normal)
        }
        if let instructionText = self.instructionText {
            self.instructionTextLabel.text = instructionText
        }
    }
}
