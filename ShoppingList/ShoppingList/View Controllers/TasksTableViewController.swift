//
//  TasksTableViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/17/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class TasksTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "SingleTaskTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "TaskCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setAppearance()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getTasks()
    }
    
    func getTasks() {
        guard let category = category, let taskController = taskController else { fatalError() }
        
        taskController.fetchTasks(categoryId: category.identifier) { (tasks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            if let tasks = tasks {
                self.tasks = nil
                let sorted = tasks.sorted(by: { (one, two) -> Bool in
                    one.dueDate.timeIntervalSince1970 < two.dueDate.timeIntervalSince1970
                })
                self.tasks = sorted.filter({ $0.isComplete == false })
                self.completedTasks = nil
                self.completedTasks = sorted.filter({ $0.isComplete == true })
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
           return tasks?.count ?? 0
        } else {
            
            if showCompleted {
                return completedTasks?.count ?? 0
            } else {
                return 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        let label = UILabel()
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        
        if section == 0 {
            
            if let category = category {
                label.text = category.name.capitalized
                label.font = AppearanceHelper.boldFont(with: .title1, pointSize: 22)
                label.textColor = .black
                label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
            }
            
        } else {
            
            if showCompleted {
                label.text = "Hide Completed"
            } else {
                label.text = "Show Completed"
            }
            
            label.font = AppearanceHelper.boldFont(with: .title2, pointSize: 16)
            label.textColor = AppearanceHelper.teal
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(completedLabelWasTapped(_:)))
            label.addGestureRecognizer(tap)
            label.isUserInteractionEnabled = true
            
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        }
        
        return view
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        guard let taskCell = cell as? SingleTaskTableViewCell,
        let tasks = tasks, let completedTasks = completedTasks,
        let userController = userController
        else { return cell }
        
        let task = indexPath.section == 0 ? tasks[indexPath.row] : completedTasks[indexPath.row]
 
        taskCell.userController = userController
        taskCell.task = task
        
        return taskCell
    }
    
    @IBAction func addTaskButtonWasTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "AddTask", sender: self)
    }
    
    @objc func completedLabelWasTapped(_ sender: UITapGestureRecognizer) {
        showCompleted = showCompleted ? false : true
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func setAppearance() {
        self.tableView.backgroundColor = AppearanceHelper.themeGray
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.separatorStyle = .none
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
            let user = currentUser, let completedTasks = completedTasks, let notesController = notesController, let notificationHelper = notificationHelper else { return }
            
            let task = index.section == 0 ? tasks[index.row] : completedTasks[index.row]
            
            destinationVC.taskController = taskController
            destinationVC.task = task
            destinationVC.category = category
            destinationVC.household = household
            destinationVC.userController = userController
            destinationVC.currentUser = user
            destinationVC.notesController = notesController
            destinationVC.notificationHelper = notificationHelper
        }
        
        if segue.identifier == "AddTask" {
            guard let destinationVC = segue.destination as? TaskViewController,
            let category = category, let household = household, let userController = userController, let user = currentUser,
            let notesController = notesController, let notificationHelper = notificationHelper else { return }
            
            destinationVC.taskController = taskController
            destinationVC.category = category
            destinationVC.household = household
            destinationVC.userController = userController
            destinationVC.currentUser = user
            destinationVC.notesController = notesController
            destinationVC.notificationHelper = notificationHelper
            
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
    
    var showCompleted: Bool = false
    
    var completedTasks: [Task]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var userController: UserController?
    var currentUser: User?
    var notesController: NotesController?
    
    var taskController: TaskController? {
        didSet {
            getTasks()
        }
    }
    
    var household: Household?
    var notificationHelper : NotificationHelper?
}
