//
//  AddTaskViewController.swift
//  ShoppingList
//
//  Created by Jerrick Warren on 5/20/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
   

    // Load sample values
    
    

    // Properties
    var categories: [Category]?
    var userController: UserController?
    var currentUser: User?
    var householdController: HouseholdController?
    var taskController = TaskController()
    var categoryController = CategoryController()
    
    var task : Task?
    var catID : UUID?
    var category : Category?
    var household : Household?
    
    //∫???
    // let tabBarController = TabViewViewController.self
    
    let mainCategoriesViewController = MainCategoriesViewController()
    
    // category reuse Identifier
    
    let reuseIdentifier = "searchCategoryCell"
    
    var filteredResults : [Category] = [] {
        didSet {
            DispatchQueue.main.async {
                self.categoryTableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchCategories()
    }
    
    
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
    
        fetchCategories()
        print(categories)
        
        
        
        
    }
    
    @objc func fetchCategories() {
        // Test Code
        guard let user = currentUser else { return }
        let householdId = user.currentHouseholdId
        categoryController.fetchCategories(householdId: householdId) { (categories, error) in
            if let error = error {
                print(error)
                return
            }
            self.categories = categories
        }
    }
    
    
    func checkCategory() {
        // check inside the filtered category
        if let category = filteredResults.first {
            self.catID = category.identifier
            self.category = category
        } else {
            guard let user = currentUser,
                  let name = addCategoryTextField.text else { return }
            let householdId = user.currentHouseholdId
           
            self.category = categoryController.createCategory(householdId: householdId, name: name)
        }
        
        
    }
    
    // IBOutlets
    
    @IBOutlet weak var categoryTableView: UITableView!
    
    @IBOutlet weak var addCategoryTextField: UITextField!
   
    @IBOutlet weak var addTaskTextField: UITextField!
    
    @IBAction func tappedCategoryTextField(_ sender: Any) {
    }
    
    @IBAction func addTaskButton(_ sender: Any) {
        
        checkCategory()
        
        guard let addTask = addTaskTextField.text ,
              let categoryID = catID
               else { return }
        
        self.task = taskController.createTask(description: addTask, categoryId: categoryID, assineeIds: [], dueDate: Date(), isComplete: false)
        
       performSegue(withIdentifier: "back2task", sender: self)
        
    
    }
    
    
    //  add the the TextField
    
    
    
    // MARK: UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
    
        print("What whould you like to go here?")
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = addCategoryTextField.text, let categories = categories else { return true }
        let filteredResults = categories.filter{$0.name.lowercased().contains(text.lowercased())}
        //let filteredNames = filteredResults.compactMap { $0.name }
        
        self.filteredResults = filteredResults
        
        return true
    }
    
    
    // Tableview protocols
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResults.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        print(cell)
        cell.textLabel?.text = filteredResults[indexPath.row].name
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selected, so set textField to relevant value, hide tableView
        // endEditing can trigger some other action according to requirements
        addCategoryTextField.text = filteredResults[indexPath.row].name
        categoryTableView.isHidden = true
        addCategoryTextField.endEditing(true)
    }
    
    // perform segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "back2task" {
            guard let destinationVC = segue.destination as? TaskViewController,
                  let task = task,
                  let category = category,
                  let currentUser = currentUser,
                  let household = household,
            let userController = userController else {return}
            
            
           
            print(task)
            print(category)
            
        
            destinationVC.taskController = taskController
            destinationVC.task = task
            destinationVC.category = category
            //destinationVC.household = household
            destinationVC.userController = userController
            //destinationVC.currentUser = currentUser
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
}

