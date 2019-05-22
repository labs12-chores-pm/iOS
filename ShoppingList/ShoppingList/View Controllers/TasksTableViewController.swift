//
//  TasksTableViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/17/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class TasksTableViewController: UITableViewController {
    
    func getTasks() {
        guard let category = category, let taskController = taskController else { return }
        
        taskController.fetchTasks(categoryId: category.identifier) { (tasks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            if let tasks = tasks {
                self.tasks = tasks.filter({ $0.isComplete == false })
                self.completedTasks = tasks.filter({ $0.isComplete == true })
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return completedTasks == nil ? 1 : 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
           return tasks?.count ?? 0
        } else {
            return completedTasks?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        if section == 0 {
            label.text = ""
        } else {
            label.text = "Completed"
        }
        return label
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        guard let tasks = tasks, let completedTasks = completedTasks else { return cell }
        
        let task = indexPath.section == 0 ? tasks[indexPath.row] : completedTasks[indexPath.row]
 
        cell.textLabel?.text = task.description
        
        return cell
    }
    
    @IBAction func addTaskButtonWasTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "AddTask", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let tasks = tasks, let taskController = taskController else { return }
            let task = tasks[indexPath.row]
            taskController.delete(task: task) { (error) in
                if let error = error {
                    print(error)
                    return
                }
                
                self.getTasks()
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTask" {
            guard let destinationVC = segue.destination as? TaskViewController,
            let index = self.tableView.indexPathForSelectedRow,
            let tasks = tasks, let category = category, let household = household, let userController = userController,
            let user = currentUser, let completedTasks = completedTasks, let notesController = notesController else { return }
            
            let task = index.section == 0 ? tasks[index.row] : completedTasks[index.row]
            
            destinationVC.taskController = taskController
            destinationVC.task = task
            destinationVC.category = category
            destinationVC.household = household
            destinationVC.userController = userController
            destinationVC.currentUser = user
            destinationVC.notesController = notesController
        }
        
        if segue.identifier == "AddTask" {
            guard let destinationVC = segue.destination as? TaskViewController,
            let category = category, let household = household, let userController = userController, let user = currentUser,
            let notesController = notesController else { return }
            
            destinationVC.taskController = taskController
            destinationVC.category = category
            destinationVC.household = household
            destinationVC.userController = userController
            destinationVC.currentUser = user
            destinationVC.notesController = notesController
        }
    }

    var category: Category?
    
    var tasks: [Task]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var completedTasks: [Task]?
    
    var userController: UserController?
    var currentUser: User?
    var notesController: NotesController?
    
    var taskController: TaskController? {
        didSet {
            getTasks()
        }
    }
    
    var household: Household?
}
