//
//  CommunicationService.swift
//  XWallet Watchkit App Extension
//
//  Created by loj on 29.07.18.
//

import Foundation
import WatchConnectivity
import WatchKit


public protocol CommunicationServiceProtocol {

    func register(receiveQrcHandler: @escaping (_ qrcImage: UIImage) -> Void)
    func register(receiveRequestIdHandler: @escaping (_ requestId: String) -> Void)
    func authenticate(requestId: String)
}


public class CommunicationService: NSObject, CommunicationServiceProtocol {

    private var receiveRequestIdHandler: ((String) -> Void)?
    private var receiveQrcHandler: ((UIImage) -> Void)?

    public override init() {
        super.init()

        if WCSession.isSupported() {
            let session  = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    public func register(receiveQrcHandler: @escaping (UIImage) -> Void) {
        self.receiveQrcHandler = receiveQrcHandler
    }

    public func register(receiveRequestIdHandler: @escaping (_ requestId: String) -> Void) {
        self.receiveRequestIdHandler = receiveRequestIdHandler
    }

    public func authenticate(requestId: String) {
        if WCSession.isSupported() {
            let message = [ApplicationContextTag.requestId.rawValue:"\(requestId)"]
            let session = WCSession.default
            do {
                print("*** watch: sending to phone: \(message)")
                try session.updateApplicationContext(message)
            } catch {
                print("*** watch: sending to phone failed: \(error)")
            }
        }
    }
}


extension CommunicationService: WCSessionDelegate {

    public func session(_ session: WCSession,
                        activationDidCompleteWith activationState: WCSessionActivationState,
                        error: Error?)
    {
        if let error = error {
            print("*** watch: WC Session activation failed with error: \(error.localizedDescription)")
            return
        }
        print("*** watch: WC Session activated successfully with state: \(activationState.rawValue)")
    }

    public func session(_ session: WCSession,
                        didReceiveApplicationContext applicationContext: [String : Any])
    {
        //print("*** watch: recieved applicationContext: \(applicationContext)")

        if let requestId = applicationContext[ApplicationContextTag.requestId.rawValue] as? String {
            print("*** watch: received a request id")
            self.receiveRequestIdHandler?(requestId)
            return
        }

        if let imageData = applicationContext[ApplicationContextTag.qrcImage.rawValue] as? Data {
            print("*** watch: received an image")
            guard let qrcImage = UIImage(data: imageData) else {
                print("*** watch: received invalid image data, exiting")
                return
            }
            self.receiveQrcHandler?(qrcImage)
            return
        }

        print("*** watch: recieved unknown tag, exiting")
    }
}








