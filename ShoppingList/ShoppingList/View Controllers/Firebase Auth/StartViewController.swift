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
            
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                
                if let error = error {
                    print(error)
                    return
                }
                
                if let user = user {
                    self.performSegue(withIdentifier: "ShowMain", sender: self)
                }
                
            }
        } else {
            
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if let error = error {
                    print(error)
                    return
                }
                
                if let user = user {
                    self.performSegue(withIdentifier: "ShowMain", sender: self)
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
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
