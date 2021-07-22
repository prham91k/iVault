//
//  WalletInvalid.swift
//  XWallet
//
//  Created by loj on 12.11.17.
//

import Foundation


public enum WalletError: Error {
    case noWalletName
    case noSeed
    
    case createFailed
    case openFailed
}
