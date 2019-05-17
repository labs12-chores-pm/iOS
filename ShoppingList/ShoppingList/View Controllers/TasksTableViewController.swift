//
//  TasksTableViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/17/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class TasksTableViewController: UITableViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getTasks()
    }
    
    func getTasks() {
        guard let category = category else { return }
        
        taskController.fetchTasks(categoryId: category.identifier) { (tasks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            if let tasks = tasks {
                self.tasks = tasks
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        guard let tasks = tasks else { return cell }
        let task = tasks[indexPath.row]
        
        if task.isComplete == false {
            cell.textLabel?.text = task.description
        }
        
        return cell
    }
    
    @IBAction func AddTaskButtonWasTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "AddTask", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let tasks = tasks else { return }
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
            let tasks = tasks, let category = category else { return }
            
            let task = tasks[index.row]
            
            destinationVC.taskController = taskController
            destinationVC.task = task
            destinationVC.category = category
        }
        
        if segue.identifier == "AddTask" {
            guard let destinationVC = segue.destination as? TaskViewController,
            let category = category else { return }
            
            destinationVC.taskController = taskController
            destinationVC.category = category
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
    
    let taskController = TaskController()
}
