//
//  WalletBuilder.swift
//  XWallet
//
//  Created by loj on 10.08.17.
//

import Foundation


public protocol WalletBuilderProtocol {
    
    func withPassword(_ password: String, andWalletName walletName: String) -> WalletBuilderProtocol
    func fromScratch() -> WalletBuilderProtocol
    func fromSeed(_ seed: Seed) -> WalletBuilderProtocol

    func openExisting() throws -> WalletProtocol
    func generate() throws -> WalletProtocol
    
}


public class WalletBuilder: WalletBuilderProtocol {
    
    private let propertyStore: PropertyStoreProtocol!
    private let secureStore: SecureStoreProtocol!
    private let fileHandling: FileHandlingProtocol!
    
    private var walletPassword: String
    private var walletName: String
    private let language = Constants.defaultWalletLanguage

    private enum CreateMode {
        case fromScratch
        case fromSeed(seed: Seed)
    }
    private var createMode: CreateMode?

    public init(propertyStore: PropertyStoreProtocol,
                secureStore: SecureStoreProtocol,
                fileHandling: FileHandlingProtocol)
    {
        self.propertyStore = propertyStore
        self.secureStore = secureStore
        self.fileHandling = fileHandling
        
        self.walletPassword = ""
        self.walletName = Constants.defaultWalletName
    }
    
    public func withPassword(_ password: String, andWalletName walletName: String) -> WalletBuilderProtocol {
        self.walletPassword = password
        self.walletName = walletName
        return self
    }
    
    public func fromScratch() -> WalletBuilderProtocol {
        self.createMode = .fromScratch
        return self
    }
    
    public func fromSeed(_ seed: Seed) -> WalletBuilderProtocol {
        self.createMode = .fromSeed(seed: seed)
        return self
    }
    
    public func openExisting() throws -> WalletProtocol {
        let success = self.openExistingWallet()
        
        if success {
            return Wallet(walletName: self.walletName,
                          propertyStore: self.propertyStore,
                          secureStore: self.secureStore,
                          fileHandling: self.fileHandling)
        }
        throw WalletError.openFailed
    }
    
    public func generate() throws -> WalletProtocol {
        var success = false
        
        if let createMode = self.createMode {
            switch createMode {
            case .fromScratch:
                success = self.createWalletFromScratch()
            case .fromSeed(let seed):
                success = self.recoverWalletFromSeed(seed)
            }
        }

        if success {
            return Wallet(walletName: self.walletName,
                          propertyStore: self.propertyStore,
                          secureStore: self.secureStore,
                          fileHandling: self.fileHandling)
        }
        throw WalletError.createFailed
    }
    
    private func createWalletFromScratch() -> Bool {
        let success = monero_createWalletFromScatch(self.pathWithFileName(),
                                                    self.walletPassword,
                                                    self.language)
        return success
    }
    
    private func recoverWalletFromSeed(_ seed: Seed) -> Bool {
        let success = monero_recoverWalletFromSeed(self.pathWithFileName(),
                                                   seed.sentence,
                                                   self.walletPassword)
        return success
    }
    
    private func openExistingWallet() -> Bool {
        let success = monero_openExistingWallet(self.pathWithFileName(),
                                                self.walletPassword)
        return success
    }
    
    private func pathWithFileName() -> String {
        let documentPath = self.fileHandling.documentPath()
        let pathWithFileName = documentPath + self.walletName
        print("### WALLET LOCATION: \(pathWithFileName)")
        
        return pathWithFileName
    }

}
