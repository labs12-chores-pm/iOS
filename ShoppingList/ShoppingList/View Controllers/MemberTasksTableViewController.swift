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
        setAppearance()
        setTasks()
        updateViews()
        
        let nib = UINib(nibName: "SingleTaskTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "TaskCell")
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
    
    private func setAppearance() {
        nameLabel.font = AppearanceHelper.styleFont(with: .title1, pointSize: 22)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 75
        self.tableView.separatorStyle = .none
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
        guard let tasks = tasks, let taskCell = cell as? SingleTaskTableViewCell,
        let categoryController = categoryController, let userController = userController else { return cell }
        let task = tasks[indexPath.row]
        
        taskCell.userController = userController
        taskCell.task = task
        taskCell.categoryController = categoryController
        
        return cell
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var household: Household?
    var member: User?
    var taskController: TaskController?
    var categoryController: CategoryController?
    var userController: UserController?
    
    var tasks: [Task]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
