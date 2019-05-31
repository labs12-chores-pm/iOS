//
//  MemberTasksTableViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/31/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class MemberTasksTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setTasks()
        updateViews()
    }
    
    private func setTasks() {
        guard let taskController = taskController,
        let member = member, let household = household
            else { fatalError() }
        
        let id = member.identifier
        
        taskController.fetchTasks(userId: id) { (memberTasks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let memberTasks = memberTasks else {
                self.displayMsg(title: "No tasks", msg: "\(member.name) doesn't have any tasks assigned to them currently.")
                return
            }
            self.tasks = memberTasks.filter({ $0.householdId == household.identifier })
        }
    }
    
    private func updateViews() {
        guard isViewLoaded, let member = member else { return }
        nameLabel.text = member.name
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        guard let tasks = tasks else { return cell }
        let task = tasks[indexPath.row]
        
        cell.textLabel?.text = task.description
        cell.detailTextLabel?.text = task.dueDate.string(style: .short, showTime: true)
        
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var household: Household?
    var member: User?
    var taskController: TaskController?
    
    var tasks: [Task]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
