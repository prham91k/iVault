//
//  WalletService.swift
//  XWallet
//
//  Created by loj on 30.11.17.
//

import Foundation


public protocol WalletLifecycleServiceProtocol {
    func lock(wallet: WalletProtocol)
    func unlockWallet(withPassword password: String) -> WalletProtocol?
}


public class WalletLifecycleService: WalletLifecycleServiceProtocol {
    
    private let propertyStore: PropertyStoreProtocol
    private let secureStore: SecureStoreProtocol
    private let walletBuilder: WalletBuilderProtocol
    
    public init(propertyStore: PropertyStoreProtocol,
                secureStore: SecureStoreProtocol,
                walletBuilder: WalletBuilderProtocol)
    {
        self.propertyStore = propertyStore
        self.secureStore = secureStore
        self.walletBuilder = walletBuilder
    }

    public func lock(wallet: WalletProtocol) {
        wallet.lock()
    }
    
    public func unlockWallet(withPassword password: String) -> WalletProtocol? {
        if !self.propertyStore.onboardingIsFinished {
            return nil
        }
        
        let walletName = Constants.defaultWalletName
        guard let wallet = try? self.walletBuilder
            .withPassword(password, andWalletName: walletName)
            .openExisting() else
        {
            return nil
        }
        
        wallet.connectToDaemon(address: self.propertyStore.nodeAddress,
                               upperTransactionSizeLimit: Constants.defaultUpperTransactionSizeLimit,
                               daemonUsername: self.secureStore.nodeUserId,
                               daemonPassword: self.secureStore.nodePassword)
        wallet.refreshWallet()
        
        return wallet
     }
}
