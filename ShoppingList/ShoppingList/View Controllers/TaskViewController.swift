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
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private func updateViews() {
        if let task = task {
            descriptionField.text = task.description
            assigneeSearch.text = assignee?.name ?? ""
            dueDatePicker.date = task.dueDate
            completeButton.setTitle("Complete", for: .normal)
        } else {
            completeButton.setTitle("Create", for: .normal)
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
    var userController = UserController()
    
    var assignee: User?
}
