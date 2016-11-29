//
//  ViewController.swift
//  EPNotificationManager
//
//  Created by Evangelos Pittas on 28/11/16.
//  Copyright © 2016 EP. All rights reserved.
//

import UIKit

import UIKit

class ViewController: UIViewController {
    
    //  MARK: - VARIABLES
    //  MARK: Outlets
    @IBOutlet weak var notificationPermissionLabel: UILabel!
    
    
    //  MARK: - INITIALIZATION
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addNotificationObservers()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        addNotificationObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //  MARK: - VIEW LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //  MARK: - SUPPORT FUNCTIONS
    
    private func updateViewController() {
        notificationPermissionLabel.text = nil
        
        NotificationManager.shared.inspectNotificationPermissions { (action) in
            
            switch action {
            case .granted:
                self.notificationPermissionLabel.text = "Permission granted"
                
            case .notPrompted:
                self.notificationPermissionLabel.text = "User hasn't been prompted for notifications"
                
            case .denied:
                self.notificationPermissionLabel.text = "Permission is denied"
            }
            
        }
    }
    
    
    //  MARK: - NOTIFICATION CENTER
    
    private func addNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(received(notification:)), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    @objc private func received(notification: Notification) {
        switch notification.name {
        case Notification.Name.UIApplicationDidBecomeActive:
            updateViewController()
            
        default:
            break
        }
    }
    

    //  MARK: - ACTIONS
    
    @IBAction func permissionButtonTapped(_ sender: UIButton) {
        NotificationManager.shared.askNotificationPermission(forTypes: [.alert, .badge, .sound]) { (error) in
            if let error = error {
                print("An error occured.\nError: \(error)")
            }
            
            self.updateViewController()
        }
    }
    
    private func askNotificationPermission() {
        //  Use this if you want to manually handle what action to take depending on the notification permission
        
        NotificationManager.shared.inspectNotificationPermissions { (action) in
            
            switch action {
            case .granted:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "", message: "You already have permission", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
            case .notPrompted:
                NotificationManager.shared.requestUserPermission(forNotificationTypes: [.alert, .badge, .sound], completionHandler: { (granted, error) in
                    self.updateViewController()
                })
                
            case .denied:
                UIApplication.shared.openAppSettings()
            }
            
        }
    }

}







































