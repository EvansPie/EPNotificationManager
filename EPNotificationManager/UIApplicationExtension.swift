//
//  UIApplicationExtension.swift
//  EPNotificationManager
//
//  Created by Evangelos Pittas on 28/11/16.
//  Copyright © 2016 EP. All rights reserved.
//

import UIKit

extension UIApplication {
    
    func openAppSettings() {
        if #available(iOS 10.0, *) {
            open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        } else {
            openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
    }
    
}
