//
//  Fiat.swift
//  XWallet
//
//  Created by loj on 23.03.18.
//

import Foundation


public enum FiatAge {
    case never
    case recent
    case moreThan10Minutes
    case moreThan1Hour
    case moreThan1Day
    
    public static func age(now: Date, pastDate: Date) -> FiatAge {
        let seconds = 1.0
        let minutes = 60.0 * seconds
        let hours = 60.0 * minutes
        let days = 24.0 * hours
        
        let duration = now.timeIntervalSince(pastDate)
        
        if duration > 1.0 * days {
            return .moreThan1Day
        }
        if duration > 1.0 * hours {
            return .moreThan1Hour
        }
        if duration > 10.0 * minutes {
            return .moreThan10Minutes
        }
        if duration >= 0.0 {
            return .recent
        }
        
        return .never
    }
}


public enum FiatEquivalent<AmountType> {
    case none
    case value(age: FiatAge, amount: AmountType)
}
