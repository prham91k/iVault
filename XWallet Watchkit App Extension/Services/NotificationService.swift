//
//  NotificationService.swift
//  XWallet Watchkit App Extension
//
//  Created by loj on 29.07.18.
//

import Foundation
import UserNotifications


public protocol NotificationServiceProtocol {

    func register(callbackForRequestId: @escaping (_ requestId: String) -> Void)
    func schedule(requestId: String)
}


public class NotificationService: NSObject, NotificationServiceProtocol {

    private let authenticateActionTag = "authenticateAction"
    private var callbackForRequestId: (String) -> Void = { _ in }

    public override init() {
        super.init()

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted {
                let authenticateAction = UNNotificationAction(identifier: self.authenticateActionTag,
                                                              title: "Authenticate",
                                                              options: .foreground)
                let xwalletCategory = UNNotificationCategory(identifier: "XWalletCategory",
                                                             actions: [authenticateAction],
                                                             intentIdentifiers: [],
                                                             options: [])

                UNUserNotificationCenter.current().setNotificationCategories([xwalletCategory])
                UNUserNotificationCenter.current().delegate = self

                print("*** watch: successfully registered notification support")
            } else {
                print("*** watch: register notification support failed: \(String(describing: error?.localizedDescription))")
            }
        }
    }

    public func register(callbackForRequestId: @escaping (String) -> Void) {
        self.callbackForRequestId = callbackForRequestId
    }

    public func schedule(requestId: String) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.alertSetting != .enabled {
                print("*** watch: notification alerts are disabled")
                return
            }

            self.removeAllOtherPendingNotifications()

            let notificationRequest = self.buildNotificationRequest(with: requestId)

            UNUserNotificationCenter.current().add(notificationRequest) { (error) in
                if let error = error {
                    print("*** watch: adding notification failed:\(error.localizedDescription)")
                } else {
                    print("*** watch: local notification was scheduled")
                }
            }
        }
    }

    private func removeAllOtherPendingNotifications() {
        UNUserNotificationCenter.current().getDeliveredNotifications { (notifications: [UNNotification]) in
            let identifiers = notifications.map { $0.request.identifier }
            print("got identifiers: \(identifiers)")
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
        }
    }

    private func buildNotificationRequest(with requestId: String) -> UNNotificationRequest {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.body = "Allow access?"
        notificationContent.categoryIdentifier = "XWalletCategory"
        notificationContent.userInfo = [ApplicationContextTag.requestId.rawValue:requestId]

        let notificationRequest = UNNotificationRequest(identifier: UUID().uuidString,
                                                        content: notificationContent,
                                                        trigger: nil)
        return notificationRequest
    }
}


extension NotificationService: UNUserNotificationCenterDelegate {

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void)
    {
        print("*** watch: did receive notification, actionIdentifier: \(response.actionIdentifier)")

        if response.actionIdentifier == self.authenticateActionTag {
            if let responseId = response.notification.request.content.userInfo[ApplicationContextTag.requestId.rawValue] as? String {
                self.callbackForRequestId(responseId)
                return
            } else {
                print("*** watch: unable to get responseId from userInfo: \(response.notification.request.content.userInfo)")
            }
        } else {
            print("*** watch: this actionIdentifier is not handled: \(response.actionIdentifier)")
        }

        completionHandler()
    }
}

















