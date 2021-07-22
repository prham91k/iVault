//
//  NotificationService.swift
//  XWallet
//
//  Created by loj on 01.08.18.
//

import Foundation
import UserNotifications


public protocol NotificationServiceProtocol {

    func schedule(requestId: String, withResponseHandler handler: (_ receivedRequestId: String) -> Void)
}


public class NotificationService: NotificationServiceProtocol {

    private let notificationCenter: UNUserNotificationCenter = {
        return UNUserNotificationCenter.current()
    }()

    public func schedule(requestId: String, withResponseHandler handler: (String) -> Void) {

        DispatchQueue.main.async { () -> Void in
//            self.notificationCenter.post(name: Notification.Name(rawValue: ),
//                                         object: self.)
        }

    }
}
