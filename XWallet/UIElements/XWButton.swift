//
//  XWButton.swift
//  XWallet
//
//  Created by loj on 15.10.17.
//

import UIKit


@IBDesignable
class XWButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 8.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setVisualDefaults()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setVisualDefaults()
    }
    
    private func setVisualDefaults() {
        self.layer.cornerRadius = self.cornerRadius
    }
}
