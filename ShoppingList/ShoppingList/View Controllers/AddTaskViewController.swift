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
        addTaskTextField.delegate = self
        
        categoryTableView.rowHeight = UITableView.automaticDimension
        
        if let tabBar = self.tabBarController as? TabViewViewController {
        
            self.taskController = tabBar.taskController
            self.currentUser = tabBar.currentUser
            self.householdController = tabBar.householdController
            self.userController = tabBar.userController
            self.categoryController = tabBar.categoryController
            self.notesController = tabBar.notesController
        } else {
            fatalError()
        }
        
        if let householdController = householdController, let user = currentUser {
            householdController.fetchHousehold(householdId: user.currentHouseholdId) { (household, error) in
                if let error = error {
                    print(error)
                    return
                }
                self.household = household
            }
        } else {
            fatalError()
        }
        
        categoryTableView.isHidden = true
        categoryTableView.alpha = 0
        
        viewTapGestureRecognizer.delegate = self
        setGestureRecogizer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let tabBar = self.tabBarController as? TabViewViewController {
            self.currentUser = tabBar.currentUser
        }
        
        if let householdController = householdController, let user = currentUser {
            householdController.fetchHousehold(householdId: user.currentHouseholdId) { (household, error) in
                if let error = error {
                    print(error)
                    return
                }
                self.household = household
            }
        } else {
            fatalError()
        }
        fetchCategories()
        updateViews()
    }
    
    @objc func fetchCategories() {
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
    
    @IBAction func addTaskButton(_ sender: Any) {
        addTask()
    }

    private func addTask() {
        guard let taskController = self.taskController,
            let household = household, let categoryController = categoryController else {
                addTaskButton.shake()
                return
        }
        
        guard let addTask = self.addTaskTextField.text, !addTask.trimmingCharacters(in: .whitespaces).isEmpty else {
            addTaskButton.shake()
            displayMsg(title: "Missing field", msg: "Please add a task description.")
            return
        }
        
        if let categoryId = self.catID {
            
            self.task = taskController.createTask(description: addTask, categoryId: categoryId, assineeIds: [], dueDate: Date(), isComplete: false, householdId: household.identifier, recurrence: Recurrence(rawValue: 0)!)
        } else if let categoryText = addCategoryTextField.text, !categoryText.isEmpty {
            
            let newCatId = UUID()
            self.catID = newCatId
            
            self.category = categoryController.createCategory(householdId: household.identifier, name: categoryText, identifier: newCatId)
            
            self.task = taskController.createTask(description: addTask, categoryId: newCatId, assineeIds: [], dueDate: Date(), isComplete: false, householdId: household.identifier, recurrence: Recurrence(rawValue: 0)!)
        } else {
            addTaskButton.shake()
            displayMsg(title: "Missing field", msg: "Please add a category.")
            return
        }
    }
    
    
    private func updateViews() {
        if filteredResults.count > 0 {
            showSearchResultsTableView()
        } else {
            hideSearchResultsTableView()
        }
    }
    
    private func showSearchResultsTableView() {
        
        viewWillLayoutSubviews()
        
        UIView.animate(withDuration: 0.2) {
            self.categoryTableView.alpha = 1
            self.categoryTableView.isHidden = false
        }
    }
    
    private func hideSearchResultsTableView() {
        
        viewWillLayoutSubviews()
        
        UIView.animate(withDuration: 0.2) {
            self.categoryTableView.alpha = 0
            self.categoryTableView.isHidden = true
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
    
    var task : Task? {
        didSet {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "back2task", sender: self)
            }
        }
    }
    
    var catID : UUID?
    var category : Category?
    var household : Household?
    
    let reuseIdentifier = "searchCategoryCell"
    
    var filteredResults : [Category] = [] {
        didSet {
            DispatchQueue.main.async {
                self.categoryTableView.reloadData()
            }
        }
    }
    
    var viewTapGestureRecognizer = UITapGestureRecognizer()
    var textFieldBeingEdited: UITextField?
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
        let selectedResult = filteredResults[indexPath.row]
        addCategoryTextField.text = selectedResult.name
        filteredResults = []
        catID = selectedResult.identifier
        category = selectedResult
        addCategoryTextField.endEditing(true)
        updateViews()
    }
}

extension AddTaskViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textFieldBeingEdited = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == addTaskTextField {
            if let taskText = addTaskTextField.text, !taskText.isEmpty {
                addTask()
            }
        }
        
        textField.resignFirstResponder()
        textFieldBeingEdited = nil
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldBeingEdited = nil
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard let text = addCategoryTextField.text, let categories = categories else { return true }

        if text.trimmingCharacters(in: .whitespaces).isEmpty {
            self.filteredResults = []
            updateViews()
            return true
        }

        let filteredResults = categories.filter{$0.name.lowercased().contains(text.lowercased())}
        self.filteredResults = filteredResults
        updateViews()
        return true
    }
}

extension AddTaskViewController: UIGestureRecognizerDelegate {
    
    private func setGestureRecogizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewWasTapped))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.cancelsTouchesInView = false
        viewTapGestureRecognizer = tapRecognizer
        view.addGestureRecognizer(viewTapGestureRecognizer)
    }
    
    @objc func viewWasTapped() {
        if let textField = textFieldBeingEdited {
            textField.resignFirstResponder()
            textFieldBeingEdited = nil
        }
    }
}

