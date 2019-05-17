//
//  LoginViewController.swift
//  ShoppingList
//
//  Created by Jerrick Warren on 5/16/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit
import FireBaseUI


class LoginViewController2: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
  
    
    @IBAction func loginPressed(_ sender: Any) {
        
        // get the authUI object
        
        // set ourselves as the delegate
        
        // get a reference to the authUI View controller
        
        // show it.
        
        FirebaseApp.configure()
        let authUI = FUIAuth.defaultAuthUI()
        
        guard authUI != nil else {
            print("There is no authUI object")
            return
        }
        
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI.delegate = self
        
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            FUIFacebookAuth(),
            FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()),
        ]
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
