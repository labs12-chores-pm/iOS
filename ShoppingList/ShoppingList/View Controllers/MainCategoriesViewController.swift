//
//  MainCategoriesViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/16/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class MainCategoriesViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
        
        if let tabBar = self.tabBarController as? TabViewViewController {
            
            self.taskController = tabBar.taskController
            self.currentUser = tabBar.currentUser
            self.householdController = tabBar.householdController
            self.userController = tabBar.userController
            self.categoryController = tabBar.categoryController
            self.notesController = tabBar.notesController
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCategories()
    }
    
    private func fetchCategories() {
        guard let user = currentUser, let categoryController = categoryController else { return }
        let householdId = user.currentHouseholdId
        categoryController.fetchCategories(householdId: householdId) { (categories, error) in
            if let error = error {
                print(error)
                return
            }
            self.categories = categories
        }
        
        if let householdController = householdController {
            householdController.fetchHousehold(householdId: householdId) { (household, error) in
                if let error = error {
                    print(error)
                    return
                }
                self.household = household
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddCategory" {
            guard let destinationVC = segue.destination as? AddCategoryViewController, let user = currentUser else { return }
            destinationVC.categoryController = categoryController
            destinationVC.currentUser = user
        }
        
        if segue.identifier == "ShowTasks" {
            guard let destinationVC = segue.destination as? TasksTableViewController,
            let index = categoriesTableView.indexPathForSelectedRow,
            let categories = categories,
            let user = currentUser,
            let taskController = taskController,
            let household = household,
            let userController = userController,
            let notesController = notesController
            else { return }
            
            let category = categories[index.row]
            
            destinationVC.currentUser = user
            destinationVC.category = category
            destinationVC.taskController = taskController
            destinationVC.household = household
            destinationVC.userController = userController
            destinationVC.notesController = notesController
        }
    }
    
    @IBOutlet weak var addCategoryButton: UIButton!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var categoriesTableView: UITableView!
    
    var taskController: TaskController?
    var userController: UserController?
    var currentUser: User?
    var householdController: HouseholdController?
    var categoryController: CategoryController?
    var notesController: NotesController?
    var categories: [Category]? {
        didSet {
            DispatchQueue.main.async {
                self.categoriesTableView.reloadData()
            }
        }
    }
    var household: Household? {
        didSet {
            DispatchQueue.main.async {
                self.updateViews()
            }
        }
    }
}

extension MainCategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        if let categories = categories {
            cell.textLabel?.text = categories[indexPath.row].name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
