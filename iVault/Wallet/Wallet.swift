//
//  Wallet.swift
//  XWallet
//
//  Created by loj on 06.08.17.
//

import Foundation


public protocol WalletDelegate {
    func walletUpdated()
    func walletSyncing(initialHeight: UInt64, walletHeight: UInt64, blockChainHeight: UInt64)
    func walletSyncCompleted()
}


public protocol WalletProtocol {
    func register(delegate: WalletDelegate)
    func unregisterDelegate()
    
    func connectToDaemon(address: String, upperTransactionSizeLimit: UInt64,
                         daemonUsername: String, daemonPassword: String)
    
    func refreshWallet()
    func lock()
    func purge()
    func setNewPassword(_ password: String)
    
    var publicAddress: PublicWalletAddress? { get }
    var seed: Seed? { get }
    
    var balance: UInt64 { get }
    var unlockedBalance: UInt64 { get }
    var history: TransactionHistory { get }
}


extension Wallet: WalletProtocol {
    
    public func register(delegate: WalletDelegate) {
        self.walletDelegate = delegate
    }
    
    public func unregisterDelegate() {
        self.walletDelegate = nil
    }
    
    public func connectToDaemon(address: String, upperTransactionSizeLimit: UInt64,
                                daemonUsername: String = "",
                                daemonPassword: String = "")
    {
        let status = monero_init(address, upperTransactionSizeLimit, daemonUsername, daemonPassword)
        Debug.print(s: "### connectToDaemon(), status=\(status)")
    }
    
    public func refreshWallet() {
        self.setListener()
        monero_startRefresh()
    }
    
    public func lock() {
        monero_closeWallet()
    }
    
    public func purge() {
        self.fileHandling.purge(wallet: self.walletName)
    }
    
    public func setNewPassword(_ password: String) {
        monero_setNewPassword(password)
    }
    
    public var publicAddress: PublicWalletAddress? {
        get {
            let publicWalletAddress = String(cString: monero_getPublicAddress())
            return PublicWalletAddress(address: publicWalletAddress)
        }
    }
    
    public var seed: Seed? {
        get {
            let sentence = String(cString: monero_getSeed(self.language))
            return Seed(sentence: sentence)
        }
    }
    
    public var balance: UInt64 {
        return monero_getBalance()
    }
    
    public var unlockedBalance: UInt64 {
        return monero_getUnlockedBalance()
    }
    
    public var history: TransactionHistory {
        return self.getUpdatedHistory()
    }
    
    private func getUpdatedHistory() -> TransactionHistory {
        let transactionHistory = TransactionHistory()
        
        guard let moneroHistory = monero_getTrxHistory() else { return transactionHistory }
        guard let transactions = moneroHistory.pointee.transactions else { return transactionHistory }
        let numberOfTransactions = moneroHistory.pointee.numberOfTransactions
        
        var unorderedHistory = [TransactionItem]()
        let swiftTransactions = InteropConverter.convert(data: transactions, elementCount: Int(numberOfTransactions))
        for swiftTransaction in swiftTransactions {
            if let swiftTransaction = swiftTransaction?.pointee {
                let historyItem = TransactionItem(direction: TransactionDirection(rawValue: Int(swiftTransaction.direction.rawValue))!,
                                                  isPending: swiftTransaction.isPending,
                                                  isFailed: swiftTransaction.isFailed,
                                                  amount: swiftTransaction.amount,
                                                  networkFee: swiftTransaction.fee,
                                                  timestamp: UInt64(swiftTransaction.timestamp),
                                                  confirmations: swiftTransaction.confirmations)
                unorderedHistory.append(historyItem)
            }
        }
        
        monero_deleteHistory(moneroHistory)
        
        // in reverse order: latest to oldest
        transactionHistory.all = unorderedHistory.sorted{ return $0.timestamp > $1.timestamp }
        return transactionHistory
    }
    
    private func setListener() {
        let handler = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        monero_registerListenerCallbacks(
            handler,
            { (handler) in
                if let handler = handler {
                    let mySelf = Unmanaged<Wallet>.fromOpaque(handler).takeUnretainedValue()
                    mySelf.listenerHandler()
                }},
            { (handler,currentHeight,blockChainHeight)  in
                if let handler = handler {
                    let mySelf = Unmanaged<Wallet>.fromOpaque(handler).takeUnretainedValue()
                    mySelf.newBlockHandler(walletHeight: currentHeight, blockChainHeight: blockChainHeight)
                }}
        )
    }
    
    private func listenerHandler() {
        self.walletDelegate?.walletUpdated()
    }
    
    private func newBlockHandler(walletHeight: UInt64, blockChainHeight: UInt64) {
        let difference = blockChainHeight.subtractingReportingOverflow(walletHeight)
        let walletIsSynced = difference.overflow || difference.partialValue < 2_000
        
        if walletIsSynced {
            Wallet.initialHeight = walletHeight
            self.walletDelegate?.walletSyncCompleted()
        } else {
            self.walletDelegate?.walletSyncing(initialHeight: Wallet.initialHeight,
                                               walletHeight: walletHeight,
                                               blockChainHeight: blockChainHeight)
        }
    }

    private static var initialHeight: UInt64 = 0
}


public class Wallet {
    
    fileprivate let language = Constants.defaultWalletLanguage
    fileprivate var propertyStore: PropertyStoreProtocol
    fileprivate var secureStore: SecureStoreProtocol
    fileprivate var fileHandling: FileHandlingProtocol
    fileprivate var walletName: String
    
    fileprivate var walletDelegate: WalletDelegate?
    
    public init(walletName: String,
                propertyStore: PropertyStoreProtocol,
                secureStore: SecureStoreProtocol,
                fileHandling: FileHandlingProtocol)
    {
        self.walletName = walletName
        self.propertyStore = propertyStore
        self.secureStore = secureStore
        self.fileHandling = fileHandling
    }
}















