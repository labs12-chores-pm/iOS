//
//  HouseholdUserTableViewCell.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/15/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class HouseholdUserTableViewCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateViews()
    }
    
    private func updateViews() {
        guard let member = member, let household = household, let currentUser = currentUser else { return }
        
        userNameLabel.text = member.name
        
        let adminIds = household.adminIds
        
        if adminIds.contains(member.identifier) || !adminIds.contains(currentUser.identifier) {
            roleSegmentedControl.isEnabled = false
        } else {
            roleSegmentedControl.isEnabled = true
        }
        
        if adminIds.contains(member.identifier) {
            roleSegmentedControl.selectedSegmentIndex = 0
        } else {
            roleSegmentedControl.selectedSegmentIndex = 1
        }
    }
    
    @IBAction func roleSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        guard let householdController = householdController, let household = household, let user = member else { return }
        
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
        householdController.updateHousehold(household: household, memberIds: household.memberIds, adminIds: adminIds, categories: household.categories ?? [])
    }
    
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var userId: UUID?
    var currentUser: User?
    var member: User?
    var householdController: HouseholdController?
    var household: Household?
    
    let roles: [Roles] = [.admin, .nonAdmin]
}

