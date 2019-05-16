//
//  CreateHouseholdViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/16/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class CreateHouseholdViewController: UIViewController {
    
    @IBAction func createButtonWasTapped(_ sender: UIButton) {
        guard let text = householdNameField.text,
            let userController = userController,
            let householdController = householdController,
            let currentUser = currentUser else { return }
        
        let newHousehold = householdController.createHousehold(name: text, creatorId: currentUser.identifier)
        userController.updateUser(user: currentUser, currentHouseholdId: newHousehold.identifier)
        
        NotificationCenter.default.post(name: NSNotification.Name("newHousehold"), object: nil)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func joinButtonWasTapped(_ sender: UIButton) {
        
    }
    
    @IBOutlet weak var householdNameField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var inviteCodeField: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    
    var householdController: HouseholdController?
    var userController: UserController?
    var currentUser: User?
}
