//
//  AppDelegate.swift
//  Shopping List
//
//  Created by Jason Modisett on 2/14/19.
//  Copyright © 2019 Jason Modisett. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
   
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()

        window = UIWindow()
        window?.makeKeyAndVisible()
        
        let loginStoryboard = UIStoryboard(name: "FirebaseLogin", bundle: .main)
        let loginVC = loginStoryboard.instantiateViewController(withIdentifier: "StartNavController")
        
        self.window?.rootViewController = loginVC
        
        return true
    }
}
