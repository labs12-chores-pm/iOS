//
//  FirebaseLoginViewController.swift
//  ShoppingList
//
//  Created by Jerrick Warren on 5/16/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

import UIKit
import Firebase
import FirebaseUI
import FirebaseAuth


class FirebaseLoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [ FUIEmailAuth(),
                                             FUIGoogleAuth(),
        ]
        authUI?.providers = providers
        
        
    }
    
    let authUI = FUIAuth.defaultAuthUI()
    
    
    @IBAction func loginTapped(_ sender: Any) {
        
        // get the default AuthUI object
        
        guard authUI != nil else {
            print("The AuthUI object is not available")
            return
        }
        
        
        
        // Set ourselves as the delegate
        authUI?.delegate = self
        
        
        // Get a reference to the auth UI view controller
       // let authViewController = authUI!.authViewController()
        
        // Show it.
       // present(authViewController, animated: true, completion: nil)
        
        let authViewController = CustomLoginViewController(authUI: authUI!)
        
        let navc = UINavigationController(rootViewController: authViewController)
        
        self.present(navc, animated: true, completion: nil)
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


extension UIViewController: FUIAuthDelegate {
    
    public func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        
        if error != nil {
            print("There is an error with auth")
            return
        }
        
      
        // you can access the UI
        
        let userID = authDataResult?.user.uid
        print("This is the UserID \(userID)")
        
        let metaData = authDataResult?.user.metadata
        print("This is the User's Meta Data \(metaData)")
        
        
        // Grab the token
        
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
            print("This is the error \(error)")
                return;
            }
            
            print("this is the usser's token \(idToken)")
            
            
            // Send token to your backend via HTTPS
            // ...
        }
        
        
        
        let mainStoryboard = UIStoryboard(name: "TabView", bundle: .main)
        let categoriesVC = mainStoryboard.instantiateViewController(withIdentifier: "TabViewViewController")
        present(categoriesVC, animated: true, completion: nil)
        
        
        
    }
    
}

