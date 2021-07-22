//
//  Payment.swift
//  XWallet
//
//  Created by loj on 17.12.17.
//

import Foundation


public protocol PaymentProtocol {
    
    var targetAddress: String? { get set }
    var amountInAtomicUnits: UInt64? { get set }
    var paymentId: String? { get set }
    var networkFeeInAtomicUnits: UInt64? {get set }
    
    var amountTotalInAtomicUnits: UInt64 { get }
    
    var keyOfPendingTransaction: Int64? { get set }
}


public class Payment: PaymentProtocol {

    public var targetAddress: String?
    public var amountInAtomicUnits: UInt64?
    public var paymentId: String?
    public var networkFeeInAtomicUnits: UInt64?
    
    public var amountTotalInAtomicUnits: UInt64 {
        get {
            return (self.amountInAtomicUnits ?? 0)
                + (self.networkFeeInAtomicUnits ?? 0)
        }
    }
    
    public var keyOfPendingTransaction: Int64?
    
    public init() {
        self.targetAddress = nil
        self.amountInAtomicUnits = nil
        self.paymentId = nil
        self.networkFeeInAtomicUnits = nil
        self.keyOfPendingTransaction = nil
    }
}
