//
//  Double-Extension.swift
//  XWallet
//
//  Created by loj on 23.03.18.
//

import Foundation


extension Double {
    
    private static let exactNumberOfFractionDigits = 2

    public func toXMR() -> UInt64? {
        if self >= Double(UInt64.min) && self * Double(Constants.atomicUnitsPerMonero) < Double(UInt64.max) {
            return UInt64(self * Double(Constants.atomicUnitsPerMonero))
        } else {
            return nil
        }
    }

    public func toCurrency() -> String {
        guard let currency = Double.currencyFormatter.string(from: NSNumber(value: self)) else {
            return ""
        }
        return currency
    }

    private static let currencyFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.allowsFloats = true
        numberFormatter.minimumIntegerDigits = 1
        numberFormatter.minimumFractionDigits = exactNumberOfFractionDigits
        numberFormatter.maximumFractionDigits = exactNumberOfFractionDigits
        return numberFormatter
    }()
}
