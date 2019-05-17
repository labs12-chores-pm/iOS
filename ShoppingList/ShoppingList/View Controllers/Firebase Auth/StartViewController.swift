//
//  StartViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/17/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit
import Firebase

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButtonWasTapped(_ sender: UIButton) {
        
        guard let email = emailField.text, let password = passwordField.text else { return }
        
        if needsNewAccount {
            
            Auth.auth().createUser(withEmail: email, password: password) { (authResponse, error) in
                
                if let error = error {
                    print(error)
                    return
                }
                
                if let authResponse = authResponse {
                    
                    let currentUser = authResponse.user
                    
                    guard let email = currentUser.email else { return }
                    
                    let userUID = UUID()
                    
                    let name = currentUser.displayName ?? email
                    let picture = currentUser.photoURL
                    
                    let household = self.householdController.createHousehold(name: name, creatorId: userUID)
                    
                    let user = self.userController.createUser(email: email, name: name, profilePicture: picture?.absoluteString, currentHouseholdId: household.identifier, identifier: userUID)
                    
                    self.currentUser = user
                }
                
            }
        } else {
            
            Auth.auth().signIn(withEmail: email, password: password) { (authResponse, error) in
                if let error = error {
                    print(error)
                    return
                }
                
                if let authResponse = authResponse {
            
                    let currentUser = authResponse.user
                    guard let email = currentUser.email else { return }
                        
                        self.userController.fetchUserWithEmail(email: email, completion: { (user, error) in
                            if let error = error {
                                print(error)
                                return
                            }
                            
                            if let user = user {
                                self.currentUser = user
                            }
                        })
        
                }
                
            }
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
    
    let userController = UserController()
    let householdController = HouseholdController()
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMain" {
            guard let destinationVC = segue.destination as? TabViewViewController else { return }
            destinationVC.userController = userController
            destinationVC.householdController = householdController
            if let user = currentUser {
                destinationVC.currentUser = user
            }
        }
    }

}
