//
//  MainCategoriesViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/16/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit
import FirebaseAuth

class MainCategoriesViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
        myToDosTableView.dataSource = self
        myToDosTableView.delegate = self
        
        if let tabBar = self.tabBarController as? TabViewViewController {
            
            self.taskController = tabBar.taskController
            self.currentUser = tabBar.currentUser
            self.householdController = tabBar.householdController
            self.userController = tabBar.userController
            self.categoryController = tabBar.categoryController
            self.notesController = tabBar.notesController
            self.notificationHelper = tabBar.notificationHelper
        } else {
            fatalError()
        }
        
        categoriesTableView.separatorStyle = .none
        categoriesTableView.tableFooterView = UIView()
        myToDosTableView.tableFooterView = UIView()
        myToDosTableView.separatorColor = FlatPink()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCategories()
        categoriesTableView.reloadData()
        myToDosTableView.reloadData()
    }
    
    private func fetchCategories() {
        guard let user = currentUser, let categoryController = categoryController else { fatalError() }
        let householdId = user.currentHouseholdId
        categoryController.fetchCategories(householdId: householdId) { (categories, error) in
            if let error = error {
                print(error)
                return
            }
            let sorted = categories?.sorted(by: { (cat1, cat2) -> Bool in
                cat1.createdAt.timeIntervalSince1970 > cat2.createdAt.timeIntervalSince1970
            })
            self.categories = sorted
            
            DispatchQueue.main.async {
                self.categoriesTableView.reloadData()
            }
        }
        
        if let householdController = householdController {
            householdController.fetchHousehold(householdId: householdId) { (household, error) in
                if let error = error {
                    print(error)
                    return
                }
                self.household = nil
                self.household = household
                
                DispatchQueue.main.async {
                    self.updateViews()
                }
            }
        } else {
            fatalError()
        }
    }
    
    private func fetchToDos() {
        guard let household = household, let currentUser = currentUser, let taskController = taskController else { return }
        
        taskController.fetchTasks(userId: currentUser.identifier) { (tasks, error) in
            if let error = error {
                print(error)
                return
            }
            
            if let tasks = tasks {
                let householdTasks = tasks.filter({ $0.householdId == household.identifier })
                let incompleteTasks = householdTasks.filter({ $0.isComplete == false })
                
                self.myTasks = incompleteTasks.sorted(by: { (task1, task2) -> Bool in
                    task1.dueDate > task2.dueDate
                })
            }
            
            DispatchQueue.main.async {
                self.myToDosTableView.reloadData()
            }
        }
    }
    
    private func updateViews() {
        guard let household = household, let user = currentUser else { return }
        
        if household.adminIds.contains(user.identifier) {
            addCategoryButton.isEnabled = true
        } else {
            addCategoryButton.isEnabled = false
        }
    }
    
    @IBAction func signOutButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            self.currentUser = nil
            try? Auth.auth().signOut()
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddCategory" {
            guard let destinationVC = segue.destination as? AddCategoryViewController, let user = currentUser else { return }
            destinationVC.categoryController = categoryController
            destinationVC.currentUser = user
        }
        
        if segue.identifier == "ShowToDo" {
            guard let destinationVC = segue.destination as? TaskViewController,
            let index = myToDosTableView.indexPathForSelectedRow,
            let tasks = myTasks, let household = household, let userController = userController, let categories = categories,
            let user = currentUser, let notesController = notesController, let notificationHelper = notificationHelper else { return }
            let task = tasks[index.row]
            let category = categories.filter { $0.identifier == task.categoryId }.first!
            
            destinationVC.taskController = taskController
            destinationVC.task = task
            destinationVC.category = category
            destinationVC.household = household
            destinationVC.userController = userController
            destinationVC.currentUser = user
            destinationVC.notesController = notesController
            destinationVC.notificationHelper = notificationHelper
        }
        
        if segue.identifier == "ShowTasks" {
            guard let destinationVC = segue.destination as? TasksTableViewController,
            let index = categoriesTableView.indexPathForSelectedRow,
            let categories = categories,
            let user = currentUser,
            let taskController = taskController,
            let household = household,
            let userController = userController,
            let notesController = notesController,
            let notificationHelper = notificationHelper
            else { return }
            
            let category = categories[index.row]
            
            destinationVC.currentUser = user
            destinationVC.category = category
            destinationVC.taskController = taskController
            destinationVC.household = household
            destinationVC.userController = userController
            destinationVC.notesController = notesController
            destinationVC.notificationHelper = notificationHelper
        }
    }
    
    @IBOutlet weak var addCategoryButton: UIButton!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var categoriesTableView: UITableView!
    @IBOutlet weak var myToDosTableView: UITableView!
    @IBOutlet weak var myToDosLabel: UILabel!
    
    var taskController: TaskController?
    var userController: UserController?
    var currentUser: User?
    var householdController: HouseholdController?
    var categoryController: CategoryController?
    var notesController: NotesController?
    var categories: [Category]?
    var household: Household? {
        didSet {
            fetchToDos()
        }
    }
    var myTasks: [Task]?
    var notificationHelper: NotificationHelper?
    
}

extension MainCategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == categoriesTableView {
            return categories?.count ?? 0
        }
        
        if tableView == myToDosTableView {
            return myTasks?.count ?? 0
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if tableView == categoriesTableView {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
            
            if let categories = categories {
                cell.textLabel?.text = categories[indexPath.row].name
                
            }
        }
        
        if tableView == myToDosTableView {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "MyToDosCell", for: indexPath)
            
            if let tasks = myTasks, let categories = categories {
                let task = tasks[indexPath.row]
                cell.textLabel?.text = "\(task.description) - \(categories[indexPath.row].name)"
                cell.detailTextLabel?.text = task.dueDate.string(style: .short, showTime: true)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if tableView != categoriesTableView { return }
        
        if editingStyle == .delete {
            guard let categories = categories, let categoryController = categoryController else { return }
            
            let category = categories[indexPath.row]
            
            categoryController.delete(category: category) { (error) in
                if let error = error {
                    print(error)
                    return
                }
                
                self.fetchCategories()
            }
        }
    }
}
