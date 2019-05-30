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
        
        guard let keychain = keychain else { fatalError() }
        
        guard let email = emailField.text else {
            getResetEmailButton.shake()
            displayMsg(title: "Missing field", msg: "Please enter your email address.")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.getResetEmailButton.shake()
                    self.displayMsg(title: "Error sending email", msg: error.localizedDescription)
                }
                return
            }
            
            keychain.delete(Settings.keychainPassword)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBOutlet weak var emailField: BlueField!
    @IBOutlet weak var getResetEmailButton: MonkeyButton!
    var keychain: KeychainSwift?
}
