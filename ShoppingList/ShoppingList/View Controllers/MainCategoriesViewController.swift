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
        myToDosTableView.dataSource = self
        myToDosTableView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        
        let nib = UINib(nibName: "SingleTaskTableViewCell", bundle: nil)
        myToDosTableView.register(nib, forCellReuseIdentifier: "TaskCell")
        
        setAppearance()
        
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
        updateUsersHousehold()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUsersHousehold()
    }
    
    private func updateUsersHousehold() {
        guard let userController = userController, let user = currentUser else { return }
        
        userController.fetchUser(userId: user.identifier) { (user, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let user = user else { return }
            self.currentUser = nil
            self.currentUser = user
            self.fetchCategories()
        }
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
                self.categoryCollectionView.reloadData()
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
    
    private func setAppearance() {
        categoriesLabel.font = AppearanceHelper.boldFont(with: .headline, pointSize: 22)
        myToDosLabel.font = AppearanceHelper.boldFont(with: .headline, pointSize: 22)
        categoriesLabel.textColor = AppearanceHelper.teal
        myToDosLabel.textColor = AppearanceHelper.teal
        
        myToDosTableView.rowHeight = UITableView.automaticDimension
        myToDosTableView.estimatedRowHeight = 150
        myToDosTableView.backgroundColor = AppearanceHelper.themeGray
        myToDosTableView.separatorStyle = .none
    }
    
    @IBAction func addCategoryButtonWasTapped(_ sender: MonkeyButton) {
        guard let household = household, let user = currentUser else { return }
        
        if household.adminIds.contains(user.identifier) {
            self.performSegue(withIdentifier: "AddCategory", sender: self)
        } else {
            displayMsg(title: "Can't Create Category", msg: "Only users with admin permission can add a category.")
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
            let indexes = categoryCollectionView.indexPathsForSelectedItems,
            let index = indexes.first,
            let categories = categories,
            let user = currentUser,
            let taskController = taskController,
            let household = household,
            let userController = userController,
            let notesController = notesController,
            let notificationHelper = notificationHelper
            else { return }
            
            let category = categories[index.item]
            
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
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var myToDosTableView: UITableView!
    @IBOutlet weak var myToDosLabel: UILabel!
    
    let collectionReuseIdentifier = "CategoryCollectionViewCell"
    
    var taskController: TaskController?
    var userController: UserController?
    var householdController: HouseholdController?
    var categoryController: CategoryController?
    var notesController: NotesController?
    var categories: [Category]?
    var currentUser: User?
    var household: Household? {
        didSet {
            fetchToDos()
        }
    }
    var myTasks: [Task]?
    var notificationHelper: NotificationHelper?
    
    var currentCategory = 0
    
}

extension MainCategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myTasks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                    
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        guard let taskCell = cell as? SingleTaskTableViewCell,
        let tasks = myTasks, let categories = categories else { return cell }
        
        let task = tasks[indexPath.row]
        let categoryArray = categories.filter { $0.identifier == task.categoryId }
        let category = categoryArray.first!
        
        taskCell.userController = userController
        taskCell.category = category
        taskCell.task = task
        
        return taskCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowToDo", sender: self)
    }
}

extension MainCategoriesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionReuseIdentifier, for: indexPath)
        
        guard let categoryCell = cell as? CategoryCollectionViewCell, let categories = categories else { return cell }
            
        let category = categories[indexPath.row]
        
        categoryCell.category = category
        
        return categoryCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let squareDimension = collectionView.bounds.width / 2
        let inset: CGFloat = 15
        
        return CGSize(width: squareDimension - inset, height: squareDimension - inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset: CGFloat = 10
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
}
