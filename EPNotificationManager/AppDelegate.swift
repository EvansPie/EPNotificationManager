//
//  AppDelegate.swift
//  EPNotificationManager
//
//  Created by Evangelos Pittas on 28/11/16.
//  Copyright © 2016 EP. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    // MARK: - APPLICATION LIFE CYCLE
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //  NotificationManager must be initialized here, since only here the UNUserNotificationCenter delegate can be set (see UNUserNotificationCenter documentation).
        _ = NotificationManager.shared
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) { }

    func applicationWillTerminate(_ application: UIApplication) { }


    // MARK: - REMOTE NOTIFICATIONS
    
    // This var is used by the NotificationManager to notify if permissions have been granted in iOS 9.
    var notificationPermissionCompletionHandler: NotificationPermissionCompletionHandler?
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if #available(iOS 10.0, *) {
            
        } else {
            //  As of iOS 9, once the user has been prompted, he is not going to be prompted again except if he uninstalls-reinstalls the app; as opposed to previous iOS versions that the user had to uninstall, wait for 1 day and then reinstall in order to be prompted again.
            //  Therefore save if the user has been prompted in the UserDefaults.

            UserDefaults.standard.set(true, forKey: "userHasBeenPrompted")
            UserDefaults.standard.synchronize()
            
            notificationPermissionCompletionHandler?(notificationSettings.types.rawValue == 0 ? false : true)
            
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("APNS token: \(deviceTokenString)")
        
        //  Here you should set the token to your server.
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register remote notifications with error: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Push notification: \(userInfo)")
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        NotificationManager.shared.applicationDidReceiveLocalNotification(notification: notification)
    }
}

