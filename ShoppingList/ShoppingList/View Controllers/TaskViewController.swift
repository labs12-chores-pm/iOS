//
//  TaskViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/17/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class TaskViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assigneeSearch.delegate = self
        
        guard let userController = userController else { return }
        
        if let task = task, let userId = task.assigneeIds.first {
            
            userController.fetchUser(userId: userId) { (user, error) in
                if let error = error {
                    print(error)
                    return
                }
                self.assignee = user
            }
        } else {
            updateViews()
        }
        
        if let household = household {
            userController.fetchUsers(inHousehold: household) { (members, error) in
                if let error = error {
                    print(error)
                    return
                }
                self.householdMembers = members
            }
        }
    }
    
    @IBAction func completeButtonWasTapped(_ sender: UIButton) {
        guard let description = descriptionField.text,
            let taskController = taskController else { return }
        
        if let task = task {
            
            var assigneeId: [UUID]!
            if let assignee = assignee {
                assigneeId = [assignee.identifier]
            } else {
                assigneeId = []
            }
            
            taskController.updateTask(task: task, description: description, assignIds: assigneeId, dueDate: dueDatePicker.date)
        } else {
            guard let categoryId = category?.identifier else { return }
            
            var assigneeId: [UUID]!
            if let assignee = assignee {
                assigneeId = [assignee.identifier]
            } else {
                assigneeId = []
            }
            
            taskController.createTask(description: description, categoryId: categoryId, assineeIds: assigneeId, dueDate: dueDatePicker.date, notes: [], isComplete: false)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    private func updateViews() {
        guard isViewLoaded else { return }
        if let task = task {
            descriptionField.text = task.description
            assigneeSearch.text = assignee?.name ?? ""
            dueDatePicker.date = task.dueDate
            completeButton.setTitle("Complete", for: .normal)
        } else {
            completeButton.setTitle("Create", for: .normal)
        }
        if let searchResult = searchResult {
            assigneeSearch.text = searchResult.name
        } else {
            if let task = task, let assigneeId = task.assigneeIds.first {
                if let assignee = householdMembers?.filter({ $0.identifier == assigneeId }).first {
                    self.searchResult = assignee
                    self.assigneeSearch.text = assignee.name
                }
            }
        }
    }
    
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var assigneeSearch: UISearchBar!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    var task: Task? {
        didSet {
            updateViews()
        }
    }
    
    var category: Category?
    var taskController: TaskController?
    var userController: UserController?
    var household: Household?
    var assignee: User?
    var householdMembers: [User]?
    var searchResult: User?
}

extension TaskViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let householdMembers = householdMembers else { return }
        let searchResults = householdMembers.filter { $0.name.contains(searchText) }
        self.searchResult = searchResults.first
        self.updateViews()
    }
}
