//
//  CustomLoginViewController.swift
//  ShoppingList
//
//  Created by Jerrick Warren on 5/22/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation
import UIKit
import FirebaseUI
import Firebase

class CustomLoginViewController: FUIAuthPickerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = UIImage(named: "logo")
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFit
        
        view.insertSubview(imageViewBackground, at: 5)
        
        
        FUIEmailAuth()
        FUIGoogleAuth()
        
        
}


    public override func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        
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



}
}
