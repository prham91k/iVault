//
//  TransactionHistory.swift
//  XWallet
//
//  Created by loj on 10.09.17.
//

import Foundation


public struct TransactionItem {

    public var direction: TransactionDirection
    public var isPending: Bool
    public var isFailed: Bool
    public let amount: UInt64
    public let networkFee: UInt64
    public let timestamp: UInt64
    public let confirmations: UInt64
    public let height: UInt64
    
    public init(direction: TransactionDirection,
                isPending: Bool,
                isFailed: Bool,
                amount: UInt64,
                networkFee: UInt64,
                timestamp: UInt64,
                confirmations: UInt64,
                height:UInt64)
    {
        self.direction = direction
        self.isPending = isPending
        self.isFailed = isFailed
        self.amount = amount
        self.networkFee = networkFee
        self.timestamp = timestamp
        self.confirmations = confirmations
        self.height = height
    }
    
    public func readableAmountWithNetworkFee() -> String {
        var totalInAtomicUnits: UInt64
        if self.isPending {
            // as long as trx is pending the amount contains the network fee
            totalInAtomicUnits = self.amount
        } else {
            // when no longer pending then the total amount spent is the sum of amount and network fee
            do{
                if((UInt64.max - self.amount) < self.networkFee) {
                    Debug.print(s: "Huge Amount : \(self.amount) Fee : \(self.networkFee)")
                    totalInAtomicUnits = self.amount
                } else {
                    totalInAtomicUnits = self.amount + self.networkFee
                }
            } catch let error as NSDecimalNumber.CalculationError {
                // Code to execute if an arithmetic overflow error was thrown
                Debug.print(s: "Arithmetic overflow error: \(error)")
            } catch let error as FloatingPoint where error.isNaN {
                // Code to execute if a floating point error (NaN) was thrown
                Debug.print(s: "Floating point error: NaN")
                totalInAtomicUnits = 0
            } catch let error as FloatingPoint where error.isInfinite {
                // Code to execute if a floating point error (infinity) was thrown
                Debug.print(s: "Floating point error: Infinity")
                totalInAtomicUnits = 0
            } catch {
                // Code to execute if an error of a different type was thrown
                Debug.print(s: "Error: \(error)")
                totalInAtomicUnits = 0
            }
        }
            
//        let floatAmount: Double = Double(totalInAtomicUnits) / 1e12
//        return String(format: "%0.05f", floatAmount)

        return CoinFormatter.format(atomicAmount: totalInAtomicUnits, numberOfFractionDigits: Constants.prettyPrintNumberOfFractionDigits)
    }
    
    private func readableAmount() -> String {
        let floatAmount: Double = Double(self.amount) / 1e12
        return String(format: "%0.05f", floatAmount)
    }
    
    private func readableNetworkFee() -> String {
        let floatNetworkFee: Double = Double(self.networkFee) / 1e12
        return String(format: "%0.05f", floatNetworkFee)
    }
    
    public func readableTimestamp() -> String {
        let date = Date(timeIntervalSince1970: Double(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
        return dateFormatter.string(from: date)
    }
    
    public func toString() -> String {
        var result = ""
        result.append("\(self.readableTimestamp())\t")
        result.append("\(self.height)\t")
        result.append("\(self.readableAmountWithNetworkFee())\t")
        result.append("\(self.readableAmount())\t")
        result.append("\(self.readableNetworkFee())\t")
        result.append("\(self.direction)\t")
        result.append("confirmations: \(self.confirmations)\t")
        result.append("pending:\(self.isPending)\t")
        result.append("failed:\(self.isFailed)\t")
        return result
    }
}


public class TransactionHistory {
    
    public var all: [TransactionItem]
    
    public init() {
        self.all = [TransactionItem]()
    }
    
    public func toString() -> String {
        var result = "\n\t\t"
        
        for transactionItem in all {
            result.append(transactionItem.toString())
            result.append("\n\t\t")
        }
        
        return result
    }
}
