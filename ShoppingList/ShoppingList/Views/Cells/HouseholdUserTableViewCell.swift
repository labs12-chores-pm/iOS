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
            self.member = user
        }
    }
    
    private func getTasks() {
        guard let taskController = taskController, let member = member else { return }
        taskController.fetchTasks(userId: member.identifier) { (tasks, error) in
            if let error = error {
                print(error)
                return
            }
            
            if let tasks = tasks {
                self.currentTasks = tasks
            }
        }
    }
    
    private func updateViews() {
        guard let user = member, let household = household, let currentUser = currentUser else { return }
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
    @IBOutlet weak var tasksTableView: UITableView! {
        didSet {
            tasksTableView.delegate = self
            tasksTableView.dataSource = self
        }
    }
    
    var userController: UserController?
    
    var userId: UUID? {
        didSet {
            getUserDetails()
        }
    }
    
    var currentUser: User?
    
    var member: User? {
        didSet {
            DispatchQueue.main.async {
                self.updateViews()
            }
        }
    }
    
    var householdController: HouseholdController?
    var household: Household?
    var taskController: TaskController?
    
    let roles: [Roles] = [.admin, .nonAdmin]
    
    var currentTasks: [Task]? {
        didSet {
            DispatchQueue.main.async {
                self.tasksTableView.reloadData()
            }
        }
    }
}

extension HouseholdUserTableViewCell: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTasks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentTasksCell", for: indexPath)
        guard let tasks = currentTasks else { return cell }
        let task = tasks[indexPath.row]
        
        cell.textLabel?.text = task.description
        cell.detailTextLabel?.text = task.dueDate.dateToString()
        
        return cell
    }
    
    
}
