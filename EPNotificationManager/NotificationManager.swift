//
//  NotificationManager.swift
//  Hopin3
//
//  Created by Evangelos Pittas on 28/09/16.
//  Copyright © 2016 Evangelos Pittas. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import CoreLocation


//  Used in iOS 9 and called from the AppDelegate
typealias NotificationPermissionCompletionHandler = ((_ granted: Bool) -> Void)


public enum PushNotificationPermission {
    case granted
    case denied
    case notPrompted
}

public enum PushNotificationType {
    case badge
    case sound
    case alert
    case carPlay
}

public enum PushNotificationSetting {
    case alertSetting
    case badgeSetting
    case carPlaySetting
    case lockScreenSetting
    case notificationCenterSetting
    case soundSetting
}


// MARK: - NOTIFICATION MANAGER

private var _NotificationManager = NotificationManager()

class NotificationManager: NSObject {
    
    // MARK: - INITIALIZATION
    
    class var shared: NotificationManager {
        return _NotificationManager
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate override init() {
        super.init()
        addNotificationObservers()
        register()
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
    }
    
    
    // MARK: - NOTIFICATION CENTER
    
    private func addNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(received(notification:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(received(notification:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    @objc private func received(notification: Notification) {
        switch notification.name {
        case NSNotification.Name.UIApplicationDidBecomeActive:
            break
            
        case NSNotification.Name.UIApplicationDidEnterBackground:
            break
            
        default:
            break
        }
    }
    
    
    // MARK: - REGISTRATION
    
    func register() {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func unregister() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }
    
    
    // MARK: - PERMISSION
    
    /**
     Check whether the user has registered for remote notifications. This doesn't mean necessarily that the user has been prompted. In case of silent notifications (i.e. you have never requested authorization to any notification setting - sound, alert, badge, etc.), the user has never been prompted but you have received a APNS token and this function will return true.
     
     - Returns: True if you have received an APNS token at anytime, false otherwise.
     */
    
    var isRegisteredForRemoteNotifications: Bool {
        return UIApplication.shared.isRegisteredForRemoteNotifications
    }
    
    func inspectNotificationPermissions(_ completionHandler: @escaping ((_ action: PushNotificationPermission) -> Void)) {
        
        hasNotificationPermission { (hasPermission) in
            
            DispatchQueue.main.async {
                if hasPermission {
                    completionHandler(.granted)
                    
                } else {
                    
                    self.hasPresentedPrompt({ (hasBeenPrompted) in
                        if hasBeenPrompted {
                            completionHandler(.denied)
                            
                        } else {
                            completionHandler(.notPrompted)
                            
                        }
                    })
                    
                }
            }
            
        }
        
    }
    
    func askNotificationPermission(forTypes notificationTypes: [PushNotificationType], completionHandler: @escaping ((_ error: Error?) -> Void)) {
        
        inspectNotificationPermissions { (notificationPermission) in
            
            switch notificationPermission {
            case .granted:
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
                
            case .denied:
                DispatchQueue.main.async {
                    let error = EPNotificationManagerError.Permission.userHasDeniedPermission
                    completionHandler(error)
                    UIApplication.shared.openAppSettings()
                }
                
            case .notPrompted:
                self.requestUserPermission(forNotificationTypes: notificationTypes, completionHandler: { (granted, error) in
                    DispatchQueue.main.async {
                        completionHandler(error)
                        
                    }
                })
                
            }
            
        }
        
    }
    
    
    /**
     Check whether the user has ever been prompted to allow Push Notifications.
     
     - parameter completionHandler: This closure returns whether the user has been prompted or not.
     */
    
    private func hasPresentedPrompt(_ completionHandler: @escaping ((_ prompted: Bool) -> Void)) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                
                DispatchQueue.main.async {
                    if settings.alertSetting != .notSupported || settings.badgeSetting != .notSupported || settings.carPlaySetting != .notSupported || settings.lockScreenSetting != .notSupported || settings.notificationCenterSetting != .notSupported || settings.soundSetting != .notSupported {
                        
                        // If either one setting has status different than 'notSupported' then the user has been prompted.
                        completionHandler(true)
                    } else {
                        completionHandler(false)
                    }
                }
                
            }
            
        } else {
            DispatchQueue.main.async {
                if UserDefaults.standard.bool(forKey: "userHasBeenPrompted") {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }
        }
    }
    
    func requestUserPermission(forNotificationTypes notificationTypes: [PushNotificationType], completionHandler: @escaping((_ granted: Bool, _ error: Error?) -> Void)) {
        if #available(iOS 10.0, *) {
            
            if notificationTypes.isEmpty {
                DispatchQueue.main.async {
                    completionHandler(false, EPNotificationManagerError.Permission.emptyPermissions)
                }
                
            } else {
                
                var options: UNAuthorizationOptions = []
                
                for notificationType in notificationTypes {
                    
                    switch notificationType {
                    case .alert:
                        options.insert(UNAuthorizationOptions.alert)
                        
                    case .badge:
                        options.insert(UNAuthorizationOptions.badge)
                        
                    case .carPlay:
                        options.insert(UNAuthorizationOptions.carPlay)
                        
                    case .sound:
                        options.insert(UNAuthorizationOptions.sound)
                        
                    }
                    
                }
                
                UNUserNotificationCenter.current().requestAuthorization(options: options, completionHandler: { (granted, error) in
                    
                    if granted {
                        // iOS 10:
                        // Register your local notifications now. Since registering notifications has occured, it won't prompt again the user.
                        //self.registerLocalInteractiveNotifications()
                    }
                    
                    DispatchQueue.main.async {
                        completionHandler(granted, error)
                    }
                    
                })
            }
            
        } else {
            
            if notificationTypes.isEmpty {
                DispatchQueue.main.async {
                    completionHandler(false, EPNotificationManagerError.Permission.emptyPermissions)
                }
                
            } else {
                var types: UIUserNotificationType = []
                
                for notificationType in notificationTypes {
                    
                    switch notificationType {
                    case .alert:
                        types.insert(UIUserNotificationType.alert)
                        
                    case .badge:
                        types.insert(UIUserNotificationType.badge)
                        
                    case .sound:
                        types.insert(UIUserNotificationType.sound)
                        
                    default:
                        break
                    }
                    
                }
                
                
                (UIApplication.shared.delegate as! AppDelegate).notificationPermissionCompletionHandler = { granted in
                    DispatchQueue.main.async {
                        if granted {
                            completionHandler(true, nil)
                        } else {
                            completionHandler(false, EPNotificationManagerError.Permission.userDidNotGrantPermission_iOS9)
                        }
                        
                        (UIApplication.shared.delegate as! AppDelegate).notificationPermissionCompletionHandler = nil
                    }
                    
                }
                
                let settings = UIUserNotificationSettings(types: types, categories: nil)
                UIApplication.shared.registerUserNotificationSettings(settings)
                
            }
            
        }
    }
    
    func hasNotificationPermission(for wantedSettings: [PushNotificationSetting]? = nil, completionHandler: @escaping((_ hasPermission: Bool) -> Void)) {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                
                var enabledNotificationSettings: [UNNotificationSetting] = []
                
                if settings.alertSetting == .enabled {
                    enabledNotificationSettings.append(settings.alertSetting)
                }
                
                if settings.badgeSetting == .enabled {
                    enabledNotificationSettings.append(settings.badgeSetting)
                }
                
                if settings.carPlaySetting == .enabled {
                    enabledNotificationSettings.append(settings.carPlaySetting)
                }
                
                if settings.lockScreenSetting == .enabled {
                    enabledNotificationSettings.append(settings.lockScreenSetting)
                }
                
                if settings.notificationCenterSetting == .enabled {
                    enabledNotificationSettings.append(settings.notificationCenterSetting)
                }
                
                if settings.soundSetting == .enabled {
                    enabledNotificationSettings.append(settings.soundSetting)
                }
                
                if (wantedSettings ?? []).isEmpty {
                    DispatchQueue.main.async {
                        if enabledNotificationSettings.count == 0 {
                            completionHandler(false)
                        } else {
                            completionHandler(true)
                        }
                    }
                    
                } else {
                    var containsAllWantedSettings: Bool = true
                    
                    for wantedSetting in wantedSettings! {
                        switch wantedSetting {
                        case .alertSetting:
                            if !enabledNotificationSettings.contains(settings.alertSetting) {
                                containsAllWantedSettings = false
                                break
                            }
                            
                        case .badgeSetting:
                            if !enabledNotificationSettings.contains(settings.badgeSetting) {
                                containsAllWantedSettings = false
                                break
                            }
                            
                        case .carPlaySetting:
                            if !enabledNotificationSettings.contains(settings.carPlaySetting) {
                                containsAllWantedSettings = false
                                break
                            }
                            
                        case .lockScreenSetting:
                            if !enabledNotificationSettings.contains(settings.lockScreenSetting) {
                                containsAllWantedSettings = false
                                break
                            }
                            
                        case .notificationCenterSetting:
                            if !enabledNotificationSettings.contains(settings.notificationCenterSetting) {
                                containsAllWantedSettings = false
                                break
                            }
                            
                        case .soundSetting:
                            if !enabledNotificationSettings.contains(settings.soundSetting) {
                                containsAllWantedSettings = false
                                break
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        completionHandler(containsAllWantedSettings)
                    }
                    
                }
                
            }
            
        } else {
            DispatchQueue.main.async {
                if let settings: UIUserNotificationSettings = UIApplication.shared.currentUserNotificationSettings {
                    if settings.types.rawValue == 0 {
                        completionHandler(false)
                        
                    } else {
                        if (wantedSettings ?? []).isEmpty {
                            if settings.types.rawValue == 0 {
                                completionHandler(false)
                            } else {
                                completionHandler(true)
                            }
                            
                        } else {
                            var containsAllWantedSettings: Bool = true
                            
                            for wantedSetting in wantedSettings! {
                                switch wantedSetting {
                                case .alertSetting:
                                    if settings.types != UIUserNotificationType.alert {
                                        containsAllWantedSettings = false
                                        break
                                    }
                                    
                                case .badgeSetting:
                                    if settings.types != UIUserNotificationType.badge {
                                        containsAllWantedSettings = false
                                        break
                                    }
                                    
                                case .soundSetting:
                                    if settings.types != UIUserNotificationType.sound {
                                        containsAllWantedSettings = false
                                        break
                                    }
                                    
                                default:
                                    break
                                }
                                
                            }
                            
                            completionHandler(containsAllWantedSettings)
                        }
                        
                    }
                    
                } else {
                    completionHandler(false)
                }
                
            }
            
        }
        
    }
    
    func logSettings() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                print("Sound settings: \(settings.soundSetting.rawValue)\nAlert setting: \(settings.alertSetting.rawValue)\nBadge settings: \(settings.badgeSetting.rawValue)\nAuthorization status: \(settings.authorizationStatus.rawValue)\nLock screen settings: \(settings.lockScreenSetting.rawValue)\nNotification center settings: \(settings.notificationCenterSetting.rawValue)")
            }
        } else {
            let settings: UIUserNotificationSettings = UIApplication.shared.currentUserNotificationSettings!
            let userNotificationTypes: UIUserNotificationType = settings.types
            print("Push notifications types: \(userNotificationTypes.rawValue)")
        }
    }
    
}














