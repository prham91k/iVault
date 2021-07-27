//
//  SecureStore.swift
//  XWallet
//
//  Created by loj on 08.02.18.
//

import Foundation


public protocol SecureStoreProtocol {
    var appPin: String? { get set }
    var walletPassword: String? { get set }
    var appleWatch2FAPassword: String? { get set }
    var nodeUserId: String { get set }
    var nodePassword: String { get set }
}


public class SecureStore: SecureStoreProtocol {
    
    private let TagAppPin = "AppPin"
    private let TagWalletPassword = "WalletPassword"
    private let TagAppleWatch2FAPassword = "AppleWatch2FAPassword"
    private let TagNodeUserId = "NodeUserId"
    private let TagNodePassword = "NodePassword"

    private let defaultStore = KeychainWrapper.default
    
    public var appPin: String? {
        get {
            return self.defaultStore.getValue(forKey: TagAppPin)
        }
        set {
            if let newValue = newValue {
                self.defaultStore.set(newValue, forKey: TagAppPin)
            } else {
                self.defaultStore.removeValue(forKey: TagAppPin)
            }
        }
    }
    
    public var walletPassword: String? {
        get {
            return self.defaultStore.getValue(forKey: TagWalletPassword)
        }
        set {
            if let newValue = newValue {
                self.defaultStore.set(newValue, forKey: TagWalletPassword)
            } else {
                self.defaultStore.removeValue(forKey: TagWalletPassword)
            }
        }
    }
    
    public var appleWatch2FAPassword: String? {
        get {
            return self.defaultStore.getValue(forKey: TagAppleWatch2FAPassword)
        }
        set {
            if let newValue = newValue {
                self.defaultStore.set(newValue, forKey: TagAppleWatch2FAPassword)
            } else {
                self.defaultStore.removeValue(forKey: TagAppleWatch2FAPassword)
            }
        }
    }

    public var nodeUserId: String {
        get {
            if let userId = self.defaultStore.getValue(forKey: TagNodeUserId) {
                return userId
            }
            return Constants.defaultNodeUserId
        }
        set {
            self.defaultStore.set(newValue, forKey: TagNodeUserId)
        }
    }
    
    public var nodePassword: String {
        get {
            if let password = self.defaultStore.getValue(forKey: TagNodePassword) {
                return password
            }
            return Constants.defaultNodePassword
        }
        set {
            self.defaultStore.set(newValue, forKey: TagNodePassword)
        }
    }
}
