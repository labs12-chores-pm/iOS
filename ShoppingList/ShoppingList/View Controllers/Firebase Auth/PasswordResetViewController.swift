//
//  PasswordResetViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/28/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit
import FirebaseAuth
import KeychainSwift

class PasswordResetViewController: UIViewController {
    
    @IBAction func resetButtonTapped(_ sender: MonkeyButton) {

        guard let email = emailField.text, let keychain = keychain else { return }
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                print(error)
                return
            }
            
            keychain.delete(Settings.keychainPassword)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBOutlet weak var emailField: BlueField!
    var keychain: KeychainSwift?
}
