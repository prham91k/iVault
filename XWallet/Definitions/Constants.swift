//
//  Constants.swift
//  XWallet
//
//  Created by loj on 22.10.17.
//

import Foundation

public class Constants {
    
    public static let defaultLanguage = "en"
    public static let defaultCurrency = "USD"
    
    public static let pinCodeLength = 6
    
    public static let defaultWalletName = "xwallet"
    public static let defaultWalletLanguage = "English"
    
    // Size in bytes for trx go be accepted
    public static let defaultUpperTransactionSizeLimit: UInt64 = 100_000
    
    public static let atomicUnitsPerMonero: UInt64 = 1_000_000_000_000
    public static let numberOfFractionDigits: Int = 12
    public static let prettyPrintNumberOfFractionDigits = 7
    
    public static let mixinCount: UInt32 = 12
    public static let defaultTransactionPriority = PendingTransactionPriority_Low
    
    public static let numberOfRequiredConfirmations: UInt64 = 10
    
    public static let defaultNodeAddress = "node.moneroworld.com:18089"
    public static let defaultNodeUserId = ""
    public static let defaultNodePassword = ""
    
    public static let donationWalletAddress = "48u79gBhhdo6Pts6daXfvn7fQ2QL9BhaqNfqTgzbgGu5fJVaX7zjTVjNXaHtj71w3y81cc9vcuH7rNiz37BC9hQuUKEcoiU"
    public static let feedbackEmail = "support@22of8.ch"
    
    public static let fiatProviderUri = "https://min-api.cryptocompare.com/data/pricemulti?fsyms=XMR&tsyms=%@"
    public static let fiatUpdateIntervalInSeconds = 30
    
    public static let feeProviderUri = "http://node.moneroworld.com:18089/json_rpc"
    public static let feeUpdateIntervalInSeconds = 30
    public static let estimatedMessageSizeInKB: Int = 13

    public static let troubleShootingLink = "https://gitlab.com/rusticbison/xwallet#troubleshooting"
    public static let privacyStatementLink = "https://gitlab.com/rusticbison/xwallet/blob/master/PRIVACY"
}
