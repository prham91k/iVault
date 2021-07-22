//
//  Colors.swift
//  XWallet
//
//  Created by loj on 25.08.18.
//

import Foundation
import UIKit


public struct Color {
    public let color: UIColor
    public let alpha: CGFloat
}


public struct ButtonColor {
    public let background: Color
    public let text: Color
}


public class Colors {

    public static let regularButtonColor = ButtonColor(background: Color(color: UIColor.black, alpha: 0.4),
                                                       text: Color(color: UIColor.white, alpha: 1.0))
    public static let warningButtonColor = ButtonColor(background: Color(color: UIColor(rgb: 0xFF8989), alpha: 1.0),
                                                       text: Color(color: UIColor.white, alpha: 1.0))
    
    public static let defaultLabelDark =  UIColor.white
    //public static let defaultLabelLight =  UIColor.black
    public static let defaultLabelLight =  UIColor.white

}
