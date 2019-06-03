//
//  MessagesTableViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/21/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class MessagesTableViewController: UITableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setAppearance()
    }
    
    private func setAppearance() {
        self.tableView.backgroundColor = AppearanceHelper.themeGray
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 75
        
    }
    
    @IBAction func backButtonWasTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        guard let messageCell = cell as? MessageTableViewCell,
        let messages = messages else { return cell }
        
        let message = messages[indexPath.row]
        
        messageCell.message = message
        
        return messageCell
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
