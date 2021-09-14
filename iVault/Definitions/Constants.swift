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
    
    public static let defaultWalletName = "default"
    public static let defaultWalletLanguage = "English"
    
    // Size in bytes for trx go be accepted
    public static let defaultUpperTransactionSizeLimit: UInt64 = 100_000
    
    //public static let atomicUnitsPerMonero: UInt64 = 1_000_000_000_000
    public static let atomicUnitsPerMonero: UInt64 = 100
    public static let numberOfFractionDigits: Int = 2
//    public static let prettyPrintNumberOfFractionDigits = 2
    public static let prettyPrintNumberOfFractionDigits = 2
    
    public static let mixinCount: UInt32 = 2
    public static let defaultTransactionPriority = PendingTransactionPriority_Low
    
    public static let numberOfRequiredConfirmations: UInt64 = 30
    
//    public static let defaultNodeAddress = "pool.scalaproject.io:8000"
    public static let defaultNodeAddress = "nodes.scalaproject.io:11812"

    public static let defaultNodeUserId = ""
    public static let defaultNodePassword = ""
    
    public static let donationWalletAddress = "Ssy2HXpWZ9RhXbb9uNFTeHjaYfexa3suDbGJDSfUWSEpSajSmjQXwLh2xqCAAUQfZrdiRkvpUZvBceT8d6zKc6aV9NaZVYXFsY"
    public static let feedbackEmail = "hello@scalaproject.io"
    
    public static let fiatProviderUri = "https://min-api.cryptocompare.com/data/pricemulti?fsyms=XLA&tsyms=%@"
    public static let fiatUpdateIntervalInSeconds = 120
    
    public static let feeProviderUri = "http://nodes.scalaproject.io:11812/json_rpc"
    public static let feeUpdateIntervalInSeconds = 60
    public static let estimatedMessageSizeInKB: Int = 13

    public static let troubleShootingLink = "https://github.com/scala-network/iVault/blob/main/docs/xwallet.md#troubleshooting"
    public static let privacyStatementLink = "https://github.com/scala-network/iVault/blob/main/PRIVACY.md"
}
