//
//  WalletViewModel.swift
//  XWallet
//
//  Created by loj on 19.11.17.
//

import Foundation


public struct WalletViewModel {
    
    public let xmrAmount: String
    public let otherAmount: String
    public let otherCurrency: String
    public let history: [TransactionItem]
    public let hasLockedBalance: Bool
    public let unlockBalance: String

    public let viewTitle: String
    public let viewTitleSyncing: String
    public let configButtonTitle: String
    public let sendButtonTitle: String
    public let receiveButtonTitle: String
    public let emptyTransactionsText: String
    public let blockChainHeight: UInt64
    public let networkHeight:UInt64

    public init(xmrAmount: String,
                otherAmount: String,
                otherCurrency: String,
                history: [TransactionItem],
                hasLockedBalance: Bool,
                unlockBalance: String,
                viewTitle: String,
                viewTitelSyncing: String,
                configButtonTitle: String,
                sendButtonTitle: String,
                receiveButtonTitle: String,
                emptyTransactionsText: String,
                blockChainHeight: UInt64,
                networkHeight:UInt64)
    {
        self.xmrAmount = xmrAmount
        self.otherAmount = otherAmount
        self.otherCurrency = otherCurrency
        self.history = history
        self.hasLockedBalance = hasLockedBalance
        self.unlockBalance = unlockBalance
        self.viewTitle = viewTitle
        self.viewTitleSyncing = viewTitelSyncing
        self.configButtonTitle = configButtonTitle
        self.sendButtonTitle = sendButtonTitle
        self.receiveButtonTitle = receiveButtonTitle
        self.emptyTransactionsText = emptyTransactionsText
        self.blockChainHeight = blockChainHeight
        self.networkHeight = networkHeight
    }
}
