//
//  BalanceFormatter.swift
//  XWallet
//
//  Created by loj on 30.11.17.
//

import Foundation


public protocol XMRFormatterProtocol {
    static func format(atomicAmount: UInt64, numberOfFractionDigits: Int) -> String
    static func fromFormatted(amount: String) -> UInt64
}


public class XMRFormatter: XMRFormatterProtocol {
    
    static public func format(atomicAmount: UInt64, numberOfFractionDigits: Int) -> String {
        let moneros = NSNumber(value: Double(atomicAmount) / Double(Constants.atomicUnitsPerMonero))
        set(numberOfFractionDigits: numberOfFractionDigits)
        guard let formatted = formatter.string(from: moneros) else {
            return ""
        }
        return formatted
    }
    
    public static func fromFormatted(amount: String) -> UInt64 {
        let decimalSeparator = Locale.current.decimalSeparator ?? "."

        var atomicUnits = ""

        var parts = amount.components(separatedBy: decimalSeparator)
        if parts.count == 1 {
            atomicUnits = parts[0] + atomicUnitsZeros
        } else if parts.count == 2 {
            atomicUnits = parts[0] + parts[1].padding(toLength: atomicUnitsPerMoneroLength, withPad: "0", startingAt: 0)
        } else {
            atomicUnits = "0"
        }
        
        return UInt64(atomicUnits) ?? 0
    }
    
    private static let atomicUnitsPerMoneroLength = 12
    private static let atomicUnitsZeros = String(repeating: "0", count: atomicUnitsPerMoneroLength)
//    private static let exactNumberOfFractionDigits = 5
    
    private static func set(numberOfFractionDigits: Int) {
        formatter.minimumFractionDigits = numberOfFractionDigits
        formatter.maximumFractionDigits = numberOfFractionDigits
    }
    
    private static var formatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.allowsFloats = true
        numberFormatter.minimumIntegerDigits = 1
        return numberFormatter
    }()
}
