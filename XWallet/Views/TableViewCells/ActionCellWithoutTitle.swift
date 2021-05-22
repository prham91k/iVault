//
//  ActionCellWithoutTitle.swift
//  XWallet
//
//  Created by loj on 02.02.18.
//

import UIKit

class ActionCellWithoutTitle: UITableViewCell {
    
    @IBOutlet weak var button: UIButton!
    
    @IBAction func buttonTouched() {
        if let handler = self.buttonTouchedHandler {
            handler()
        }
    }
    
    public var buttonTitle: String?
    public var buttonTouchedHandler: (() -> Void)?
    
    public func redraw() {
        self.showData()
    }
    
    private func showData() {
        if let buttonTitle = self.buttonTitle {
            self.button.setTitle(buttonTitle, for: .normal)
        }
    }
}
