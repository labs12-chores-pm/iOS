//
//  HouseholdUserTableViewCell.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/15/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class HouseholdUserTableViewCell: UITableViewCell {
    
    private func getUserDetails() {
        guard let userController = userController, let userId = userId else { return }
        userController.fetchUser(userId: userId) { (user, error) in
            if let error = error {
                print(error)
                return
            }
            self.user = user
        }
    }
    
    private func updateViews() {
        guard let user = user, let household = household, let currentUser = currentUser else { return }
        userNameLabel.text = user.name
        
        let adminIds = household.adminIds
        
        if adminIds.contains(currentUser.identifier) {
            roleSegmentedControl.isEnabled = false
        }
        
        if adminIds.contains(user.identifier) {
            roleSegmentedControl.selectedSegmentIndex = 0
        } else {
            roleSegmentedControl.selectedSegmentIndex = 1
        }
        
        let dummyTask = Task(description: "Some task", categoryId: UUID(), assigneeIds: [user.identifier], dueDate: Date(), notes: [], identifier: UUID(), isComplete: false)
        let dummyTask2 = Task(description: "Some task 2", categoryId: UUID(), assigneeIds: [user.identifier], dueDate: Date(), notes: [], identifier: UUID(), isComplete: false)
        
        currentTasks.append(dummyTask)
        currentTasks.append(dummyTask2)
        
        currentTaskLabel.text = currentTasks[0].description
        nextTaskLabel.text = currentTasks[1].description
    }
    
    @IBAction func roleSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        guard let householdController = householdController, let household = household, let user = user else { return }
        
        var adminIds = household.adminIds
        
        switch sender.selectedSegmentIndex {
        case 0:
            if !household.adminIds.contains(user.identifier) {
                adminIds += [user.identifier]
            }
        default:
            for (int, id) in adminIds.enumerated() {
                if id == user.identifier {
                    adminIds.remove(at: int)
                }
            }
        }
        
        householdController.updateHousehold(household: household, memberIds: household.memberIds, adminIds: adminIds, categories: household.categories)
    }
    
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var currentTaskLabel: UILabel!
    @IBOutlet weak var nextTaskLabel: UILabel!
    
    var userController: UserController?
    
    var userId: UUID? {
        didSet {
            getUserDetails()
        }
    }
    
    var currentUser: User?
    
    var user: User? {
        didSet {
            updateViews()
        }
    }
    
    var householdController: HouseholdController?
    var household: Household?
    
    let roles: [Roles] = [.admin, .nonAdmin]
    
    var currentTasks: [Task] = []
}
