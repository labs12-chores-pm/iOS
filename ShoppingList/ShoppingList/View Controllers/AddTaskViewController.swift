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
    
    
    var sampleCategories = ["Kitchen", "Bathroom", "Dining Room", "Living Room" ,"Master Bedroom"]
    var sampleTask = ["Clean up", "Wipe Down", "Wash dishes", "Vaccum", ]
    
    // Properties
    var categories: [Category]?
    var userController: UserController?
    var currentUser: User?
    var householdController: HouseholdController?
    var taskController = TaskController()
    var categoryController = CategoryController()
    
    //∫???
    // let tabBarController = TabViewViewController.self
    
    let mainCategoriesViewController = MainCategoriesViewController()
    
    // category reuse Identifier
    
    let reuseIdentifier = "searchCategoryCell"
    
    var filteredResults : [String] = [] {
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
        
        fetchCategories()
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
    
    
    
    // IBOutlets
    
    @IBOutlet weak var categoryTableView: UITableView!
    
    @IBOutlet weak var addCategoryTextField: UITextField!
   
    @IBOutlet weak var addTextField: UITextField!
    
    @IBAction func tappedCategoryTextField(_ sender: Any) {
    }
    
    @IBAction func addTaskButton(_ sender: Any) {
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
        let filteredNames = filteredResults.compactMap { $0.name }
        
        self.filteredResults = filteredNames
        
        return true
    }
    
    
    // Tableview protocols
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResults.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        print(cell)
        cell.textLabel?.text = filteredResults[indexPath.row]
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selected, so set textField to relevant value, hide tableView
        // endEditing can trigger some other action according to requirements
        addCategoryTextField.text = filteredResults[indexPath.row]
        tableView.isHidden = true
        addCategoryTextField.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    
    
    
    
}

//
// extension MainCategoriesViewController: UITableViewDelegate, UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return categories?.count ?? 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
//
//        if let categories = categories {
//            cell.textLabel?.text = categories[indexPath.row].name
//        }
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            guard let categories = categories else { return }
//
//            let category = categories[indexPath.row]
//
//            categoryController.delete(category: category) { (error) in
//                if let error = error {
//                    print(error)
//                    return
//                }
//
//                self.fetchCategories()
//            }
//        }
// }


