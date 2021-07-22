//
//  2FAService.swift
//  XWallet
//
//  Created by loj on 01.08.18.
//

import Foundation


public enum TwoFactorAuthenticationResult {
    case authenticated
    case notAvailable
    case failed
}


public protocol TwoFactorAuthenticationServiceProtocol {

    func authenticateOnWatch(with responseHandler: @escaping (_ authenticationResult: TwoFactorAuthenticationResult) -> Void)
}


public class TwoFactorAuthenticationService: TwoFactorAuthenticationServiceProtocol {

    private let watchCommunicationService: WatchCommunicationServiceProtocol

    private var responseHandler: ((TwoFactorAuthenticationResult) -> Void)?
    private var requestId: String = ""

    public init(watchCommunicationService: WatchCommunicationServiceProtocol) {
        self.watchCommunicationService = watchCommunicationService
    }

    public func authenticateOnWatch(with responseHandler: @escaping (_ authenticationResult: TwoFactorAuthenticationResult) -> Void)
    {
        switch self.watchCommunicationService.getConnectivityState() {
        case .notSupported, .watchAppNotInstalled:
            self.responseWithError(to: responseHandler)
        case .ok:
            self.requestAuthorization(with: responseHandler)
        }
    }

    private func responseWithError(to handler: (_ authenticationResult: TwoFactorAuthenticationResult) -> Void) {
        self.responseHandler = nil
        handler(.notAvailable)
    }

    private func requestAuthorization(with responseHandler: @escaping (_ authenticationResult: TwoFactorAuthenticationResult) -> Void) {
        self.responseHandler = responseHandler
        self.requestId = UUID().uuidString

        self.watchCommunicationService.register(receiveHandler: self.receive)
        self.watchCommunicationService.requestAuthentication(requestId: self.requestId)
    }

    private func receive(responseId: String) {
        if responseId == self.requestId {
            self.responseHandler?(.authenticated)
        } else {
            self.responseHandler?(.failed)
        }
    }
}
