//
//  AppDelegate.swift
//  Shopping List
//
//  Created by Jason Modisett on 2/14/19.
//  Copyright © 2019 Jason Modisett. All rights reserved.
//

import UIKit
import Firebase


let defaults = UserDefaults.standard

//, UNUserNotificationCenterDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
   
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

<<<<<<< HEAD
      FirebaseApp.configure()
=======
        FirebaseApp.configure()
>>>>>>> ff05580a30f6ee2ce8781e811f30204b0256a477
        
        
//        PushNotifications.shared.start(instanceId: "1c17ef2c-92ea-486e-af1b-7bc8faa62607")
//        PushNotifications.shared.registerForRemoteNotifications()
//
//        UNUserNotificationCenter.current().delegate = self
//      //  try? self.pushNotifications.subscribe(interest: "group-103")
//
//
//        let center = UNUserNotificationCenter.current()
//        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
//            if (granted) {
//                DispatchQueue.main.async(execute: {
//                    application.registerForRemoteNotifications()
//                })
//            }
//        }
//
        window = UIWindow()
        window?.makeKeyAndVisible()
//
//        let loginVC = LoginViewController.instantiate()
//        let mainVC = MainViewController.instantiate()
        
<<<<<<< HEAD
        
        
        let mainStoryboard = UIStoryboard(name: "FirebaseLogin", bundle: .main)
        let categoriesVC = mainStoryboard.instantiateViewController(withIdentifier: "FirebaseLogin")
        self.window?.rootViewController = categoriesVC
=======
        let mainStoryboard = UIStoryboard(name: "TabView", bundle: .main)
        let categoriesVC = mainStoryboard.instantiateViewController(withIdentifier: "TabViewViewController")
        
        let loginStoryboard = UIStoryboard(name: "FirebaseLogin", bundle: .main)
        let loginVC = loginStoryboard.instantiateViewController(withIdentifier: "StartViewController")
        
        self.window?.rootViewController = loginVC
>>>>>>> ff05580a30f6ee2ce8781e811f30204b0256a477
        
//        self.window?.rootViewController = SessionManager.tokens == nil ? loginVC : mainVC
        
        return true
    }
//
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken : Data) {
//        PushNotifications.shared.registerDeviceToken(deviceToken)
//        print(deviceToken)
//    }
//
//    func application(
//        _ application: UIApplication,
//        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
//        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
//    ) {
//        PushNotifications.shared.handleNotification(userInfo: userInfo)
//        print(userInfo)
//        completionHandler(.newData)
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
//    {
//        completionHandler([.alert, .badge, .sound])
//    }
}
