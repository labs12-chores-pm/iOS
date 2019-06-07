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
            let tasksInHousehold = memberTasks.filter({ $0.householdId == household.identifier })
            
            self.tasks = tasksInHousehold.filter({ $0.isComplete == false })
            self.completedTasks = tasksInHousehold.filter({ $0.isComplete == true })
        }
    }
    
    private func setAppearance() {
        nameLabel.font = AppearanceHelper.styleFont(with: .title1, pointSize: 22)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 75
        self.tableView.separatorStyle = .none
        self.view.backgroundColor = AppearanceHelper.themeGray
    }
    
    private func updateViews() {
        guard isViewLoaded, let member = member else { return }
        nameLabel.text = member.name
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return tasks?.count ?? 0
        } else {
            return completedTasks?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        guard let tasks = tasks, let completedTasks = completedTasks, let taskCell = cell as? SingleTaskTableViewCell,
        let categoryController = categoryController, let userController = userController else { return cell }
        
        let task = indexPath.section == 0 ? tasks[indexPath.row] : completedTasks[indexPath.row]
        
        taskCell.userController = userController
        taskCell.task = task
        taskCell.categoryController = categoryController
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        
        if section == 0 {
             label.text = "Current Tasks"
        } else if section == 1 {
            label.text = "Completed Tasks"
        }
        
        let view = UIView()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        
        label.font = AppearanceHelper.boldFont(with: .title1, pointSize: 14)
        label.textColor = .black
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        
        return view
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
    
    var completedTasks: [Task]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
