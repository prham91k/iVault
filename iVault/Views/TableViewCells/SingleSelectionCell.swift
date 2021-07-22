//
//  SingleSelectionCell.swift
//  XWallet
//
//  Created by loj on 22.01.18.
//

import UIKit

class SingleSelectionCell: UITableViewCell {
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var checkmarkView: UIView!
    
    public var value: String?
    public var checkmarkIsSet: Bool?
    public var id: String?
    
    public func redraw() {
        self.showData()
    }
    
    private func showData() {
        if let value = self.value {
            self.valueLabel.text = value
        }
        if let checkmarkIsSet = self.checkmarkIsSet {
            self.checkmarkView.isHidden = !checkmarkIsSet
        } else {
            self.checkmarkView.isHidden = true
        }
    }
}
