//
//  NotificationManagerError.swift
//  EPNotificationManager
//
//  Created by Evangelos Pittas on 28/11/16.
//  Copyright © 2016 EP. All rights reserved.
//

import Foundation

struct EPNotificationManagerError {
    
    enum Permission: Error {
        case emptyPermissions
        case userDidNotGrantPermission_iOS9
        case userHasNotBeenPrompted
        case userHasDeniedPermission
        
        var debugDescription: String {
            switch self {
            case .emptyPermissions:
                return "The notification permission array is empty."
                
            case .userDidNotGrantPermission_iOS9:
                return "User did not grant notification permission (iOS 9)."
                
            case .userHasNotBeenPrompted:
                return "User has not been prompted yet for notification permission."
                
            case .userHasDeniedPermission:
                return "User has denied notification access."

            }
        }
    }
    
}



















