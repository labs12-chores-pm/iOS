//
//  MessagesTableViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/21/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class MessagesTableViewController: UITableViewController {
    
    @IBAction func backButtonWasTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        guard let messages = messages, let userController = userController else { return cell }
        
        if let message = messages[indexPath.row] as? Task {
            cell.textLabel?.text = "\(message.description) is awaiting approval"
        }
        
        if let message = messages[indexPath.row] as? Note {
            cell.textLabel?.text = message.text
            userController.fetchUser(userId: message.memberId) { (user, error) in
                if let error = error {
                    print(error)
                } else {
                    guard let user = user else { return }
                    DispatchQueue.main.async {
                       cell.detailTextLabel?.text = user.name
                    }
                }
            }
        }

        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTask" {
            guard let index = tableView.indexPathForSelectedRow, let messages = messages,
            let userController = userController, let currentUser = currentUser,
            let household = household, let taskController = taskController,
            let destinationVC = segue.destination as? TaskViewController else { return }
            
            destinationVC.userController = userController
            destinationVC.currentUser = currentUser
            destinationVC.household = household
            
            if let task = messages[index.row] as? Task {
            
                destinationVC.task = task
            } else if let note = messages[index.row] as? Note {
                
                taskController.fetchSingleTask(taskId: note.taskId) { (task, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    guard let task = task else { return }
                    destinationVC.task = task
                }
            }
        }
    }
    
    var messages: [Any]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                UserDefaults.standard.set(self.messages?.count, forKey: "MessageCount")
            }
        }
    }
    var userController: UserController?
    var currentUser: User?
    var taskController: TaskController?
    var householdController: HouseholdController?
    var household: Household?
    var notesController: NotesController?
}
