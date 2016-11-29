//
//  NotificationManagerExtension.swift
//  EPNotificationManager
//
//  Created by Evangelos Pittas on 28/11/16.
//  Copyright © 2016 EP. All rights reserved.
//

import UIKit
import UserNotifications


//  MARK: - iOS 10 NOTIFICATION CENTER DELEGATE

@available(iOS 10.0, *)
extension NotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
    }
    
}

//  MARK: - iOS 9 LOCAL NOTIFICATION

extension NotificationManager {
    
    @available(iOS, deprecated: 10.0, message: "Because UILocalNotification has been deprecated")
    func applicationDidReceiveLocalNotification(notification: UILocalNotification) {
        
    }
    
}


















