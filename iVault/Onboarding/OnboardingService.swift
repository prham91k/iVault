//
//  OnboardingProtocol.swift
//  XWallet
//
//  Created by loj on 31.07.17.
//

import Foundation


public protocol OnboardingServiceProtocol {
    
    func hasWallet(withWalletName walletName: String) -> Bool
    
    func setAppPin(_ appPin: String)
    func setWalletName(_ walletName: String)
    func setSeed(_ seed: Seed)
    
    func createNewWallet() throws -> WalletProtocol
    func recoverWallet() throws -> WalletProtocol
    func purgeWallet()
    
}


public class OnboardingService: OnboardingServiceProtocol {

    private var walletBuilder: WalletBuilderProtocol
    private var propertyStore: PropertyStoreProtocol
    private var secureStore: SecureStoreProtocol
    
    private var wallet: WalletProtocol?
    private var walletName: String?
    private var seed: Seed?
    
    private var appPin: String?
    private var walletPassword: String = ""
    
    public init(walletBuilder: WalletBuilderProtocol,
                propertyStore: PropertyStoreProtocol,
                secureStore: SecureStoreProtocol)
    {
        self.walletBuilder = walletBuilder
        self.propertyStore = propertyStore
        self.secureStore = secureStore
    }
    
    public func hasWallet(withWalletName walletName: String) -> Bool {
        //@@TODO  "check for wallet with given name"
        return self.propertyStore.onboardingIsFinished
    }
    
    public func setAppPin(_ appPin: String) {
        self.appPin = appPin
    }
    
    public func setWalletName(_ walletName: String) {
        self.walletName = walletName
    }
    
    public func setSeed(_ seed: Seed) {
        self.seed = seed
    }
    
    public func createNewWallet() throws -> WalletProtocol {
        guard let walletName = self.walletName else {
            throw WalletError.noWalletName
        }
        self.walletPassword = PasswordGenerator.create()
        
        if let wallet = try? self.walletBuilder
            .withPassword(self.walletPassword, andWalletName: walletName)
            .fromScratch()
            .generate()
        {
            self.setOnboardingFinished()
            self.connectToDemon(wallet: wallet)
            self.wallet = wallet
            return wallet
        }
        
        throw WalletError.createFailed
    }
    
    public func recoverWallet() throws -> WalletProtocol {
        guard let walletName = self.walletName else {
            throw WalletError.noWalletName
        }
        guard let seed = self.seed else {
            throw WalletError.noSeed
        }
        self.walletPassword = PasswordGenerator.create()
        
        if let wallet = try? self.walletBuilder
            .withPassword(self.walletPassword, andWalletName: walletName)
            .fromSeed(seed)
            .generate()
        {
            self.setOnboardingFinished()
            self.connectToDemon(wallet: wallet)
            self.wallet = wallet
            return wallet
        }

        throw WalletError.createFailed
    }
    
    public func purgeWallet() {
        guard let wallet = self.wallet else {
            return
        }
        wallet.lock()
        wallet.purge()

        self.secureStore.walletPassword = nil
        self.propertyStore.onboardingIsFinished = false
    }

    private func setOnboardingFinished() {
        self.secureStore.appPin = self.appPin
        self.secureStore.walletPassword = self.walletPassword
        self.propertyStore.onboardingIsFinished = true
    }
    
    private func connectToDemon(wallet: WalletProtocol) {
        wallet.connectToDaemon(address: self.propertyStore.nodeAddress,
                               upperTransactionSizeLimit: Constants.defaultUpperTransactionSizeLimit,
                               daemonUsername: self.secureStore.nodeUserId,
                               daemonPassword: self.secureStore.nodePassword)
        wallet.refreshWallet()
    }
}














