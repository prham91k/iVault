//
//  FiatService.swift
//  XWallet
//
//  Created by loj on 11.03.18.
//

import Foundation


public protocol FiatServiceProtocol {
    func startUpdating(withIntervalInSeconds interval: Int,
                       notificationHandler: @escaping () -> Void)
    func stopUpdating()
    
    func getXMR(forFiatValue fiatValue: Double) -> FiatEquivalent<UInt64>
    func getFiat(forXMRValue xmrValue: UInt64) -> FiatEquivalent<Double>
}


public class FiatService: FiatServiceProtocol {
    
    private let fiatProvider: FiatProviderProtocol
    private let dateProvider: DateProviderProtocol
    private var propertyStore: PropertyStoreProtocol
    
    private var updateIntervalInSeconds: Int = 5
    private var timer: Timer?
    private var notificationHandler: (() -> Void)?
    
    public init(fiatProvider: FiatProviderProtocol,
                dateProvider: DateProviderProtocol,
                propertyStore: PropertyStoreProtocol)
    {
        self.fiatProvider = fiatProvider
        self.dateProvider = dateProvider
        self.propertyStore = propertyStore
    }
    
    public func startUpdating(withIntervalInSeconds interval: Int,
                              notificationHandler: @escaping () -> Void)
    {
        self.updateIntervalInSeconds = interval
        self.notificationHandler = notificationHandler
        self.queryFiatFactor()
    }
    
    public func stopUpdating() {
        self.stopTimer()
        self.notificationHandler = nil
    }
    
    public func getXMR(forFiatValue fiatValue: Double) -> FiatEquivalent<UInt64> {
        guard let fiatFactor = self.propertyStore.lastFiatFactor,
            let updateDate = self.propertyStore.lastFiatUpdate else {
            return FiatEquivalent<UInt64>.none
        }
        
        let xmrValue = UInt64(fiatValue / fiatFactor) * Constants.atomicUnitsPerMonero
        let age = self.ageFor(updateDate)
        
        return FiatEquivalent.value(age: age, amount: xmrValue)
    }
    
    public func getFiat(forXMRValue xmrValue: UInt64) -> FiatEquivalent<Double> {
        guard let fiatFactor = self.propertyStore.lastFiatFactor,
            let updateDate = self.propertyStore.lastFiatUpdate else {
            return FiatEquivalent<Double>.none
        }
        
        let xmr = Double(xmrValue) / Double(Constants.atomicUnitsPerMonero)
        let fiatValue = xmr * fiatFactor
        let age = self.ageFor(updateDate)
        
        return FiatEquivalent.value(age: age, amount: fiatValue)
    }
    
    private func store(_ factor: Double, forCurrency currency: String) {
        if self.hasChanged(currency) {
            self.propertyStore.lastFiatFactor = nil
            self.propertyStore.lastFiatUpdate = nil
        } else {
            self.propertyStore.lastFiatFactor = factor
            self.propertyStore.lastFiatUpdate = self.dateProvider.now()
        }
    }
    
    private func hasChanged(_ currency: String) -> Bool {
        return self.propertyStore.currency != currency
    }
    
    private func notify() {
        self.notificationHandler?()
    }
    
    private func ageFor(_ updateDate: Date) -> FiatAge {
        return FiatAge.age(now: self.dateProvider.now(), pastDate: updateDate)
    }
    
    private func scheduleNextQuery() {
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(self.updateIntervalInSeconds),
                                              repeats: false,
                                              block: { _ in
                                                self.queryFiatFactor() })
        }
    }
    
    private func stopTimer() {
        self.timer?.invalidate()
    }
    
    private func queryFiatFactor() {
        self.fiatProvider.getFiatEquivalent(
            forCurrency: self.propertyStore.currency,
            completionHandler: { factor,currency  in self.fiatFactorReceived(factor, forCurrency: currency) },
            failedHandler: { () in self.fiatFactorReceiveFailed() })
    }
    
    private func fiatFactorReceived(_ factor: Double, forCurrency currency: String) {
        self.stopTimer()
        self.store(factor, forCurrency: currency)
        self.notify()
        self.scheduleNextQuery()
    }
    
    private func fiatFactorReceiveFailed() {
        self.stopTimer()
        self.notify()
        self.scheduleNextQuery()
    }
}









