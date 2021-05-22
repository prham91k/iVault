//
//  FeeService.swift
//  XWallet
//
//  Created by loj on 01.05.18.
//

import Foundation


public protocol FeeServiceProtocol {
    func startUpdating(withIntervalInSeconds interval: Int,
                       notificationHandler: @escaping () -> Void)
    func stopUpdating()
    
    func getFeeInAtomicUnits(forMessageSizeInKB messageSize: Int) -> UInt64
}


public class FeeService: FeeServiceProtocol {
    
    private let feeProvider: FeeProviderProtocol
    private var propertyStore: PropertyStoreProtocol
    
    private var updateIntervalInSeconds: Int = 3600
    private var timer: Timer?
    private var notificationHandler: (() -> Void)?
    
    public init(feeProvider: FeeProviderProtocol,
                propertyStore: PropertyStoreProtocol)
    {
        self.feeProvider = feeProvider
        self.propertyStore = propertyStore
    }
    
    public func startUpdating(withIntervalInSeconds interval: Int, notificationHandler: @escaping () -> Void) {
        self.updateIntervalInSeconds = interval
        self.notificationHandler = notificationHandler
        self.queryFee()
    }
    
    public func stopUpdating() {
        self.stopTimer()
        self.notificationHandler = nil
    }
    
    public func getFeeInAtomicUnits(forMessageSizeInKB messageSize: Int) -> UInt64 {
        let totalFeeInAtomicUnits = self.propertyStore.feeInAtomicUnits * UInt64(messageSize)
        return totalFeeInAtomicUnits
    }
    
    private func queryFee() {
        self.feeProvider.getEstimatedFee(
            completionHandler: { (fee: UInt64) in self.feeValueReceived(feeInAtomicUnits: fee)},
            failedHandler: {() in self.feeValueReceivedFailed() })
    }
    
    private func stopTimer() {
        self.timer?.invalidate()
    }
    
    private func feeValueReceived(feeInAtomicUnits: UInt64) {
        self.stopTimer()
        self.store(feeInAtomicUnits)
        self.notify()
        self.scheduleNextQuery()
    }
    
    private func feeValueReceivedFailed() {
        self.stopTimer()
        self.scheduleNextQuery()
    }
    
    private func store(_ feeInAtomicUnits: UInt64) {
        self.propertyStore.feeInAtomicUnits = feeInAtomicUnits
    }
    
    private func scheduleNextQuery() {
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(self.updateIntervalInSeconds),
                                              repeats: false,
                                              block: { _ in self.queryFee() })
        }
    }
    
    private func notify() {
        self.notificationHandler?()
    }
}
