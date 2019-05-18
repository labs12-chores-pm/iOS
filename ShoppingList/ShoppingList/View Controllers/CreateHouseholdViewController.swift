//
//  CreateHouseholdViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/16/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class CreateHouseholdViewController: UIViewController {
    
    private func updateViews() {
        if isJoinForm {
            createJoinButton.setTitle("Join", for: .normal)
            createNameInviteCodeField.placeholder = "Enter Join Code..."
        } else {
            createJoinButton.setTitle("Create", for: .normal)
            createNameInviteCodeField.placeholder = "Enter Household Name..."
        }
    }
    
    @IBAction func createJoinButtonWasTapped(_ sender: UIButton) {
        guard let text = createNameInviteCodeField.text,
        let userController = userController,
        let householdController = householdController,
        let currentUser = currentUser else { return }
        
        var newHousehold: Household!
        if isJoinForm {
            
        } else {
            newHousehold = householdController.createHousehold(name: text, creatorId: currentUser.identifier)
        }

        userController.updateUser(user: currentUser, currentHouseholdId: newHousehold.identifier)        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func joinCreateSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            isJoinForm = true
        case 1:
            isJoinForm = false
        default:
            break
        }
        updateViews()
    }
    
    @IBOutlet weak var createNameInviteCodeField: UITextField!
    @IBOutlet weak var createJoinButton: UIButton!
    
    var householdController: HouseholdController?
    var userController: UserController?
    var currentUser: User?
    var isJoinForm: Bool = true
}
