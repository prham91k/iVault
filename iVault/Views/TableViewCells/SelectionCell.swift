//
//  SelectionCell.swift
//  XWallet
//
//  Created by loj on 21.01.18.
//

import UIKit


public class SelectionCell: UITableViewCell {
    
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var selectedValueLabel: UILabel!
    
    @IBAction func buttonTouched() {
        if let handler = self.buttonTouchedHandler {
            handler()
        }
    }
    
    public var cellTitle: String?
    public var selectedValue: String?
    public var buttonTouchedHandler: (() -> Void)?
    
    public func redraw() {
        self.showData()
    }
    
    private func showData() {
        if let cellTitle = self.cellTitle {
            self.cellTitleLabel.text = cellTitle
        }
        if let selectedValue = self.selectedValue {
            self.selectedValueLabel.text = selectedValue
        }
    }
}
