//
//  DateProvider.swift
//  XWallet
//
//  Created by loj on 23.03.18.
//

import Foundation


public protocol DateProviderProtocol {
    func now() -> Date
}

public class DateProvider: DateProviderProtocol {
    public init() {}
    public func now() -> Date {
        return Date()
    }
}
