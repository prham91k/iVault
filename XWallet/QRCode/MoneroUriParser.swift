//
//  QRCScanner.swift
//  XWallet
//
//  Created by loj on 10.06.18.
//

import Foundation


public struct PaymentParameters {
    public var walletAddress: String?
    public var paymentId: String?
    public var amount: String?
    public var description: String?

    public init() {}
}

public enum MoneroUriParseResult {
    case ok
    case invalidWalletAddress
    case invalidPaymentId
    case invalidAmount
    case invalidDescription
}

public protocol MoneroUriParserProtocol {
    func process(_ uri: String) -> (parseResult: MoneroUriParseResult, payment: PaymentParameters)
}


public class MoneroUriParser: MoneroUriParserProtocol {

    public init() {}

    public func process(_ uri: String) -> (parseResult: MoneroUriParseResult, payment: PaymentParameters) {
        let parsedParameters = self.parse(uri)
        let checkResult = self.check(parsedParameters)
        return (parseResult: checkResult, parsedParameters)
    }

    private func parse(_ uri: String) -> PaymentParameters {
        let parameterDictionary = self.makeDictionaryFrom(uri)

        var parameters = PaymentParameters()
        parameters.walletAddress = parameterDictionary["monero"]
        parameters.paymentId = parameterDictionary["tx_payment_id"]
        parameters.amount = parameterDictionary["tx_amount"]
        parameters.description = parameterDictionary["tx_description"]

        return parameters
    }

    private func makeDictionaryFrom(_ uri: String) -> [String:String] {
        guard let url = URL(string: uri) else {
            return [String:String]()
        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!

        var dictionary = [String:String]()
        if let queryItems = components.queryItems {
            for item in queryItems {
                dictionary[item.name] = item.value!
            }
        }

        dictionary[components.scheme ?? "monero"] = components.path

        return dictionary
    }

    private func check(_ paymentParameters: PaymentParameters) -> MoneroUriParseResult {
        if false == self.isValid(walletAddress: paymentParameters.walletAddress) {
            return .invalidWalletAddress
        }

        if false == self.isValid(paymentId: paymentParameters.paymentId) {
            return .invalidPaymentId
        }
        
        if false == self.isValid(amount: paymentParameters.amount) {
            return .invalidAmount
        }
        
        if false == self.isValid(description: paymentParameters.description) {
            return .invalidDescription
        }
        
        return .ok
    }

    private func isValid(walletAddress: String?) -> Bool {
        guard let walletAddress = walletAddress else {
            return false
        }
        let isValid = monero_isValidWalletAddress(walletAddress)
        return isValid
    }
    
    private func isValid(paymentId: String?) -> Bool {
        guard let paymentId = paymentId else {
            // is optional
            return true
        }
        let isValid = monero_isValidPaymentId(paymentId)
        return isValid
    }
    
    private func isValid(amount: String?) -> Bool {
        guard let amount = amount else {
            // is optional
            return true
        }
        guard let _ = Double(amount) else {
            return false
        }
        return true
    }
    
    private func isValid(description: String?) -> Bool {
//        guard let description = description else {
//            // is optional
//            return true
//        }
        //TODO define conditions for check
        return true
    }
}















