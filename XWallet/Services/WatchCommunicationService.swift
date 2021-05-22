//
//  CommunicationService.swift
//  XWallet
//
//  Created by loj on 30.07.18.
//

import Foundation
import UIKit
import WatchConnectivity


public enum WatchConnectivityState {
    case ok
    case notSupported
    case watchAppNotInstalled
}


public protocol WatchCommunicationServiceProtocol {

    func getConnectivityState() -> WatchConnectivityState
    func register(receiveHandler: @escaping (_ requestId: String) -> Void)
    func requestAuthentication(requestId: String)
    func sendQRC(image: UIImage)
}


public class WatchCommunicationService: NSObject, WatchCommunicationServiceProtocol {

    private var receiveHandler: ((String) -> Void)?

    public override init() {
        super.init()

        if WCSession.isSupported() {
            let session  = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    public func getConnectivityState() -> WatchConnectivityState {
        guard WCSession.isSupported() else {
            return .notSupported
        }
        guard WCSession.default.isWatchAppInstalled else {
            return .watchAppNotInstalled
        }
        return .ok
    }

    public func register(receiveHandler: @escaping (String) -> Void) {
        self.receiveHandler = receiveHandler
    }

    public func requestAuthentication(requestId: String) {
        guard WCSession.isSupported() else {
            print("*** phone: WCSession not supported")
            return
        }

        let session = WCSession.default
        guard session.isWatchAppInstalled else {
            print("*** phone: watch app not installed")
            return
        }

        let message = [ApplicationContextTag.requestId.rawValue:requestId]
        do {
            print("*** phone: sending to watch: \(message)")
            try session.updateApplicationContext(message)
        } catch {
            print("*** phone: sending to watch failed: \(error)")
        }
    }

    public func sendQRC(image: UIImage) {
        guard WCSession.isSupported() else {
            print("*** phone: WCSession not supported")
            return
        }

        let session = WCSession.default
        guard session.isWatchAppInstalled else {
            print("*** phone: watch app not installed")
            return
        }

        guard let imageData = image.toData() else {
            print("*** phone: unable to get image data")
            return
        }

        let message = [ApplicationContextTag.qrcImage.rawValue:imageData]
        do {
            print("*** phone: sending QRC to watch: \(message)")
            try session.updateApplicationContext(message)
        } catch {
            print("*** phone: sending QRC to watch failed: \(error)")
        }
    }
}


extension WatchCommunicationService: WCSessionDelegate {

    public func session(_ session: WCSession,
                        activationDidCompleteWith activationState: WCSessionActivationState,
                        error: Error?)
    {
        if let error = error {
            print("*** phone: WC Session activation failed with error: \(error.localizedDescription)")
            return
        }
        print("*** phone: WC Session activated successfully with state: \(activationState.rawValue)")
    }

    public func sessionDidBecomeInactive(_ session: WCSession) {
        print("*** phone: session did become inactive")
    }

    public func sessionDidDeactivate(_ session: WCSession) {
        print("*** phone: session did deactivate")
    }

    public func session(_ session: WCSession,
                        didReceiveApplicationContext applicationContext: [String : Any])
    {
        print("*** phone: received applicationContext: \(applicationContext)")

        guard let requestId = applicationContext[ApplicationContextTag.requestId.rawValue] as? String else {
            print("*** phone: did not receive a request id, existing")
            return
        }

        self.receiveHandler?(requestId)
    }
}
