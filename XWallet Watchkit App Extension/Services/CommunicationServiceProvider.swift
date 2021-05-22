//
//  CommunicationServiceProvider.swift
//  XWallet Watchkit App Extension
//
//  Created by loj on 30.07.18.
//

import Foundation


public protocol CommunicationServiceProviderProtocol {

    static func current() -> CommunicationServiceProtocol
}


public class CommunicationServiceProvider: CommunicationServiceProviderProtocol {

    public static func current() -> CommunicationServiceProtocol {
        return communicationService
    }

    private static var communicationService = {
        return CommunicationService()
    }()
}
