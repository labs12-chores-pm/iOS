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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
    }
    
    @IBAction func resetButtonTapped(_ sender: MonkeyButton) {
        
        guard let keychain = keychain else { fatalError() }
        
        guard let email = emailField.text else {
            getResetEmailButton.shake()
            displayMsg(title: "Missing field", msg: "Please enter your email address.")
            return
        }
        
        let activityView = getActivityView()
        activityView.startAnimating()
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.getResetEmailButton.shake()
                    self.displayMsg(title: "Error sending email", msg: error.localizedDescription)
                }
                return
            }
            
            keychain.delete(Settings.keychainPassword)
            activityView.stopAnimating()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func setAppearance() {
        passwordResetLabel.font = AppearanceHelper.styleFont(with: .body, pointSize: 18)
    }
    
    @IBOutlet weak var emailField: BlueField!
    @IBOutlet weak var getResetEmailButton: MonkeyButton!
    @IBOutlet weak var passwordResetLabel: UILabel!
    
    var keychain: KeychainSwift?
}
