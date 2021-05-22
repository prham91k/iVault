//
//  ActionCellWithSubTitle.swift
//  XWallet
//
//  Created by loj on 21.01.18.
//

import UIKit

class ActionCellWithSubTitle: UITableViewCell {

    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var cellSubTitleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    @IBAction func buttonTouched() {
        if let handler = self.buttonTouchedHandler {
            handler()
        }
    }
    
    public var cellTitle: String?
    public var cellSubTitle: String?
    public var buttonTitle: String?
    public var buttonTouchedHandler: (() -> Void)?
    
    public func redraw() {
        self.showData()
    }
    
    private func showData() {
        if let cellTitle = self.cellTitle {
            self.cellTitleLabel.text = cellTitle
        }
        if let cellSubTitle = self.cellSubTitle {
            self.cellSubTitleLabel.text = cellSubTitle
        }
        if let buttonTitle = self.buttonTitle {
            self.button.setTitle(buttonTitle, for: .normal)
        }
    }
}
