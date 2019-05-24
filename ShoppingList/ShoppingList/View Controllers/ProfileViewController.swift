//
//  ProfileViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/24/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let tabBar = self.tabBarController as? TabViewViewController,
            let authResponse = tabBar.authResponse, let currentUser = tabBar.currentUser, let userController = tabBar.userController {
            
            self.authResponse = authResponse
            self.currentUser = currentUser
            self.userController = userController
        }
        
        userNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        updateViews()
    }
    
    private func updateViews() {
        guard isViewLoaded, let authResponse = authResponse else { fatalError() }
        
        let authUser = authResponse.user
        
        userNameField.text = authUser.displayName
        emailField.text = authUser.email
        
        saveChangesButton.alpha = 0
        saveChangesButton.isEnabled = false
        saveChangesButton.isHidden = true
    }
    
    @IBAction func saveChangesButtonTapped(_ sender: MonkeyButton) {
        
        guard let authResponse = authResponse, let userController = userController, let currentUser = currentUser else { fatalError() }
        
        if let displayName = userNameField.text, !displayName.isEmpty {
            
            let changeRequest = authResponse.user.createProfileChangeRequest()
            
            changeRequest.displayName = displayName
            
            changeRequest.commitChanges { (error) in
                if let error = error {
                    self.displayMsg(title: "Error updating user name", msg: "\(error)")
                    print(error)
                    return
                }
                
                userController.updateUser(user: currentUser, name: displayName)
            }
            
        }
        
        if let email = emailField.text, !email.isEmpty {
            
            authResponse.user.updateEmail(to: email) { (error) in
                if let error = error {
                    self.displayMsg(title: "Error updating email", msg: "\(error)")
                    print(error)
                    return
                }
                
                userController.updateUser(user: currentUser, email: email)
            }
            
        }
        
        if let password = passwordField.text, !password.isEmpty {
            
            authResponse.user.updatePassword(to: password) { (error) in
                if let error = error {
                    self.displayMsg(title: "Error updating password", msg: "\(error)")
                    print(error)
                    return
                }
            }
        }
    }
    
    @IBAction func signOutButtonTapped(_ sender: DiscreteButton) {
        self.dismiss(animated: true) {
            self.currentUser = nil
            try? Auth.auth().signOut()
        }
    }
    
    private func showSaveButton() {
        
        viewWillLayoutSubviews()
        
        UIView.animate(withDuration: 0.2) {
            self.saveChangesButton.alpha = 1
            self.saveChangesButton.isEnabled = true
            self.saveChangesButton.isHidden = false
        }
    }

    @IBOutlet weak var userNameField: BlueField!
    @IBOutlet weak var emailField: BlueField!
    @IBOutlet weak var passwordField: BlueField!
    @IBOutlet weak var saveChangesButton: MonkeyButton!
    
    var authResponse: AuthDataResult?
    var currentUser: User?
    var userController: UserController?
}

extension ProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        showSaveButton()
    }
}
