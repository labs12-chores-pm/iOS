//
//  AddTaskViewController.swift
//  ShoppingList
//
//  Created by Jerrick Warren on 5/20/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        addCategoryTextField.delegate = self
        
        categoryTableView.rowHeight = UITableView.automaticDimension
        
        if let tabBar = self.tabBarController as? TabViewViewController {
        
            self.taskController = tabBar.taskController
            self.currentUser = tabBar.currentUser
            self.householdController = tabBar.householdController
            self.userController = tabBar.userController
            self.categoryController = tabBar.categoryController
            self.notesController = tabBar.notesController
        }
        
        if let householdController = householdController, let user = currentUser {
            householdController.fetchHousehold(householdId: user.currentHouseholdId) { (household, error) in
                if let error = error {
                    print(error)
                    return
                }
                self.household = household
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchCategories()
    }
    
    @objc func fetchCategories() {
        // Test Code
        guard let user = currentUser else { return }
        let householdId = user.currentHouseholdId
        categoryController?.fetchCategories(householdId: householdId) { (categories, error) in
            if let error = error {
                print(error)
                return
            }
            self.categories = categories
        }
    }
    
    func checkCategory() {

        if let category = filteredResults.first {
            self.catID = category.identifier
            self.category = category
        } else {
            guard let user = currentUser,
                  let name = addCategoryTextField.text else { return }
            let householdId = user.currentHouseholdId
            self.category = categoryController?.createCategory(householdId: householdId, name: name)
        }
    }
    
    @IBAction func addTaskButton(_ sender: Any) {
        
        checkCategory()
        
        guard let addTask = self.addTaskTextField.text,
        let categoryID = self.catID, let taskController = self.taskController,
        let household = household else {
            addTaskButton.shake()
            return
        }
  
        displayMsg(title: "Please Confirm", msg: "Are you sure you want to add this task?", style: .alert) { (isConfirmed) in
            
    
            if let isConfirmed = isConfirmed, isConfirmed == true {
                
                self.task = taskController.createTask(description: addTask, categoryId: categoryID, assineeIds: [], dueDate: Date(), isComplete: false, householdId: household.identifier)
                
                
                self.performSegue(withIdentifier: "back2task", sender: self)
            }
        }
    }
    
    // perform segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "back2task" {
            guard let destinationVC = segue.destination as? TaskViewController,
                  let task = task,
                  let category = category,
                  let currentUser = currentUser,
                  let household = household,
            let userController = userController,
            let notesController = notesController,
            let taskController = taskController
            else {return}
            
            destinationVC.taskController = taskController
            destinationVC.task = task
            destinationVC.category = category
            destinationVC.household = household
            destinationVC.userController = userController
            destinationVC.currentUser = currentUser
            destinationVC.notesController = notesController
        }
    }
    
    // IBOutlets
    
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var addCategoryTextField: UITextField!
    @IBOutlet weak var addTaskTextField: UITextField!
    @IBOutlet weak var addTaskButton: MonkeyButton!
    
    @IBAction func tappedCategoryTextField(_ sender: Any) {
    }
    
    // Properties
    var categories: [Category]?
    var userController: UserController?
    var currentUser: User?
    var householdController: HouseholdController?
    var taskController : TaskController?
    var categoryController : CategoryController?
    var notesController: NotesController?
    
    var task : Task?
    var catID : UUID?
    var category : Category?
    var household : Household?
    
    //    let mainCategoriesViewController = MainCategoriesViewController()
    
    let reuseIdentifier = "searchCategoryCell"
    
    var filteredResults : [Category] = [] {
        didSet {
            DispatchQueue.main.async {
                self.categoryTableView.reloadData()
            }
        }
    }
    
}

extension AddTaskViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResults.count > 0 ? 1 : 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        print(cell)
        cell.textLabel?.text = filteredResults[indexPath.row].name
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addCategoryTextField.text = filteredResults[indexPath.row].name
        filteredResults = []
        addCategoryTextField.endEditing(true)
    }
}

extension AddTaskViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = addCategoryTextField.text, let categories = categories else { return true }
        let filteredResults = categories.filter{$0.name.lowercased().contains(text.lowercased())}
        
        self.filteredResults = filteredResults
        
        return true
    }
}

