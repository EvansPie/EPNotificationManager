//
//  InteractiveNotifications.swift
//  EPNotificationManager
//
//  Created by Evangelos Pittas on 28/11/16.
//  Copyright © 2016 EP. All rights reserved.
//

import UserNotifications
import UIKit


public enum NotificationCategory: String {
    case testCategory = "test_category"
}

public enum NotificationAction: String {
    case noAction = "no_action"
    case yesAction = "yes_action"
    
    var title: String {
        switch self {
        case .noAction:
            return "No"
            
        case .yesAction:
            return "Yes"
        }
    }
}

extension NotificationManager {
    
    func registerInteractiveNotifications() {
        if #available(iOS 10.0, *) {
            // 1. Create actions
            //    YES action
            let yesAction = UNNotificationAction(
                identifier: NotificationAction.yesAction.rawValue,
                title: NotificationAction.yesAction.title,
                options: [])
            //    NO action
            let noAction = UNNotificationAction(
                identifier: NotificationAction.noAction.rawValue,
                title: NotificationAction.noAction.title,
                options: [])
            
            // 2. Create category and register its actions
            let category = UNNotificationCategory(
                identifier: NotificationCategory.testCategory.rawValue,
                actions: [yesAction, noAction],
                intentIdentifiers: [],
                options: [])
            
            // 3. Set the categories in the notification center.
            UNUserNotificationCenter.current().setNotificationCategories([category])
            
            // 4. Register notifications (if permission is already granted then nothing will happen, otherwise user will be prompted).
            UNUserNotificationCenter.current().requestAuthorization(options: [UNAuthorizationOptions.alert, UNAuthorizationOptions.sound]) { (granted, error) in
                
            }
            
        } else {
            // 1. Create the actions
            //    YES action
            let yesAction = UIMutableUserNotificationAction()
            yesAction.identifier = NotificationAction.yesAction.rawValue
            yesAction.title = NotificationAction.yesAction.title
            yesAction.activationMode = UIUserNotificationActivationMode.background
            yesAction.isAuthenticationRequired = false
            yesAction.isDestructive = false
            //    NO action
            let noAction = UIMutableUserNotificationAction()
            noAction.identifier = NotificationAction.noAction.rawValue
            noAction.title = NotificationAction.noAction.title
            noAction.activationMode = UIUserNotificationActivationMode.background
            noAction.isAuthenticationRequired = false
            noAction.isDestructive = false
            
            // 2. Create category and register its actions
            let category = UIMutableUserNotificationCategory()
            category.identifier = NotificationCategory.testCategory.rawValue
            category.setActions([yesAction, noAction], for: .default)
            category.setActions([yesAction, noAction], for: .minimal)
            
            // 3. Register notifications (if permission is already granted then nothing will happen, otherwise user will be prompted).
            let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert,  UIUserNotificationType.sound]
            let settings = UIUserNotificationSettings(types: notificationTypes, categories: [category])
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }
    
}
