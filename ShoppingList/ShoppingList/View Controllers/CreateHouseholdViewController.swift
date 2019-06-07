//
//  CreateHouseholdViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/16/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class CreateHouseholdViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createNameInviteCodeField.delegate = self
        viewTapGestureRecognizer.delegate = self
        setGestureRecogizer()
    }
    
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
        guard let text = createNameInviteCodeField.text else {
            createJoinButton.shake()
            displayMsg(title: "Missing field", msg: "Please enter \(isJoinForm ? "an invite code" : "a household name").")
            return
        }
        
        guard let userController = userController,
        let householdController = householdController,
        let currentUser = currentUser else { fatalError() }
        
        if isJoinForm {
            
            householdController.fetchHousehold(inviteCode: text) { (household, error) in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let household = household else { return }
                
                let members = household.memberIds + [currentUser.identifier]
                
                householdController.updateHousehold(household: household, memberIds: members, adminIds: household.adminIds, categories: household.categories ?? [])
                
                userController.updateUser(user: currentUser, currentHouseholdId: household.identifier)
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        } else {
            let newHousehold = householdController.createHousehold(name: text, creatorId: currentUser.identifier)
            
            userController.updateUser(user: currentUser, currentHouseholdId: newHousehold.identifier)
            self.navigationController?.popViewController(animated: true)
        }
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
    @IBOutlet weak var createJoinButton: MonkeyButton!
    
    var householdController: HouseholdController?
    var userController: UserController?
    var currentUser: User?
    var isJoinForm: Bool = true
    
    var viewTapGestureRecognizer = UITapGestureRecognizer()
    var textFieldBeingEdited: UITextField?
}

extension CreateHouseholdViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldBeingEdited = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldBeingEdited = nil
        textField.resignFirstResponder()
        return true
    }
}

extension CreateHouseholdViewController: UIGestureRecognizerDelegate {
    
    private func setGestureRecogizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewWasTapped))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.cancelsTouchesInView = false
        viewTapGestureRecognizer = tapRecognizer
        view.addGestureRecognizer(viewTapGestureRecognizer)
    }
    
    @objc func viewWasTapped() {
        if let textField = textFieldBeingEdited {
            textField.resignFirstResponder()
            textFieldBeingEdited = nil
        }
    }
}
