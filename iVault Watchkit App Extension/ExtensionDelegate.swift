//
//  ExtensionDelegate.swift
//  XWallet Watchkit App Extension
//
//  Created by loj on 15.07.18.
//

import WatchKit


class ExtensionDelegate: NSObject, WKExtensionDelegate {

    private var notificationService: NotificationServiceProtocol!
    private var communicationService: CommunicationServiceProtocol!

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        self.setup()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    private func setup() {
        self.notificationService = NotificationService()
        self.communicationService = CommunicationServiceProvider.current()

        self.notificationService.register(callbackForRequestId: { (requestId: String) in
            self.handleNotification(requestId: requestId)
        })

        self.communicationService.register(receiveRequestIdHandler: { (requestId: String) in
            self.handleCommunication(requestId: requestId)
        })

        self.communicationService.register(receiveQrcHandler: { (qrcImage: UIImage) in
            self.handleCommunication(qrcImage: qrcImage)
        })
    }

    private func handleNotification(requestId: String) {
        self.communicationService.authenticate(requestId: requestId)
    }

    private func handleCommunication(requestId: String) {
        if WKExtension.shared().applicationState == .background {
            print("*** watch: is in background")
            self.notificationService.schedule(requestId: requestId)
        } else {
            print("*** watch: is in foreground")
            let context = [ApplicationContextTag.requestId.rawValue:requestId]
            DispatchQueue.main.async {
                WKInterfaceController.reloadRootPageControllers(
                    withNames: ["MainView"],
                    contexts: [context],
                    orientation: WKPageOrientation.vertical,
                    pageIndex: 0)
            }
        }
    }

    private func handleCommunication(qrcImage: UIImage) {
        if WKExtension.shared().applicationState == .background {
            print("*** watch: is in background")
//            self.notificationService.schedule(requestId: requestId)
        } else {
            print("*** watch: is in foreground")
            let context = [ApplicationContextTag.qrcImage.rawValue:qrcImage]
            DispatchQueue.main.async {
                WKInterfaceController.reloadRootPageControllers(
                    withNames: ["MainView"],
                    contexts: [context],
                    orientation: WKPageOrientation.vertical,
                    pageIndex: 0)
            }
        }
    }
}












