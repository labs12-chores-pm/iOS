//
//  StartViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/17/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tryKeychainLogin()
    }
    
    private func tryKeychainLogin() {
        guard let email = keychain.get(Settings.keychainEmail), let password = keychain.get(Settings.keychainPassword) else { return }
        signIn(email: email, password: password)
    }
    
    private func signIn(email: String, password: String) {
        
        let activityView = getActivityView()
        activityView.startAnimating()
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResponse, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.loginButton.shake()
                    self.displayMsg(title: "Error signing in...", msg: error.localizedDescription)
                }
                return
            }
            
            if let authResponse = authResponse {
                
                self.authResponse = authResponse
                
                let currentUser = authResponse.user
                guard let email = currentUser.email else { return }
                
                self.userController.fetchUserWithEmail(email: email, completion: { (user, error) in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.loginButton.shake()
                            self.displayMsg(title: "Error signing in...", msg: error.localizedDescription)
                        }
                        return
                    }
                    
                    if let user = user {
                        self.currentUser = user
                        
                        if self.keychain.get(Settings.keychainEmail) == nil {
                            self.keychain.set(email, forKey: Settings.keychainEmail)
                        }
                        
                        if self.keychain.get(Settings.keychainPassword) == nil {
                            self.keychain.set(password, forKey: Settings.keychainPassword)
                        }
                    }
                })
            }
            DispatchQueue.main.async {
                activityView.stopAnimating()
            }
        }
    }
    
    func showActivityView() {
        
    }
    
    @IBAction func loginButtonWasTapped(_ sender: UIButton) {
        
        guard let email = emailField.text, let password = passwordField.text else { return }
        
        if needsNewAccount {
            
            let activityView = getActivityView()
            activityView.startAnimating()
            
            Auth.auth().createUser(withEmail: email, password: password) { (authResponse, error) in
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.loginButton.shake()
                        self.displayMsg(title: "Error creating account...", msg: error.localizedDescription)
                    }
                    return
                }
                
                if let authResponse = authResponse {
                
                    self.authResponse = authResponse
                    
                    let currentUser = authResponse.user
                    
                    guard let email = currentUser.email else {
                        DispatchQueue.main.async {
                            self.loginButton.shake()
                            self.displayMsg(title: "Something went wrong...", msg: "Email address wasn't found. Please try again later.")
                        }
                        return
                    }
                    
                    let userUID = UUID()
                    
                    let name = currentUser.displayName ?? email
                    let picture = currentUser.photoURL
                    
                    let household = self.householdController.createHousehold(name: name, creatorId: userUID, memberIds: [userUID])
                    
                    let user = self.userController.createUser(email: email, name: name, profilePicture: picture?.absoluteString, currentHouseholdId: household.identifier, identifier: userUID)
                    
                    self.currentUser = user
                    
                    self.keychain.set(email, forKey: Settings.keychainEmail)
                    self.keychain.set(password, forKey: Settings.keychainPassword)
                }
                DispatchQueue.main.async {
                    activityView.stopAnimating()
                }
            }
        } else {
            signIn(email: email, password: password)
        }
    }
    
    
    @IBAction func loginSignUpControlValueChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            needsNewAccount = false
        case 1:
            needsNewAccount = true
        default:
            break
        }
    }
    
    var needsNewAccount: Bool = false
    
    var currentUser: User? {
        didSet {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ShowMain", sender: self)
            }
        }
    }
    
    var authResponse: AuthDataResult?
    
    let userController = UserController()
    let householdController = HouseholdController()
    let keychain = KeychainSwift()
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: MonkeyButton!
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMain" {
            guard let destinationVC = segue.destination as? TabViewViewController,
            let authResponse = authResponse
            else { return }
            destinationVC.authResponse = authResponse
            destinationVC.userController = userController
            destinationVC.householdController = householdController
            if let user = currentUser {
                destinationVC.currentUser = user
            }
            destinationVC.keychain = keychain
        }
        
        if segue.identifier == "ShowPasswordReset" {
            guard let passwordResetVC = segue.destination as? PasswordResetViewController else { return }
            passwordResetVC.keychain = keychain
        }
    }

}
