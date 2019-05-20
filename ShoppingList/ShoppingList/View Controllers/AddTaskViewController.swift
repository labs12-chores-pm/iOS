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
    
    // category reuse Identifier
    
    let reuseIdentifier = "searchCategoryCell"
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

      //  categoriesTableView.dataSource = self
      //  categoriesTableView.delegate = self
        
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
            // ??
            // self.categories = categories
        }
    }
    
    
    
    
    
    
    // IBOutlets
    
  
    @IBOutlet weak var addCategoryTextField: UITextField!
   
    @IBOutlet weak var addTextField: UITextField!
    
    @IBAction func tappedCategoryTextField(_ sender: Any) {
    }
    
    @IBAction func addTaskButton(_ sender: Any) {
    }
    
    
    
    
    //  add the the TextField
    
    // Properties
    
    var userController: UserController?
    var currentUser: User?
    var householdController: HouseholdController?
    var taskController = TaskController()
    var categoryController = CategoryController()
    
    //∫???
   // let tabBarController = TabViewViewController.self
    
    let mainCategoriesViewController = MainCategoriesViewController()
    
    // MARK: UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        // TODO: Your app can do something when textField finishes editing
        print("The textField ended editing. Do something based on app requirements.")
    }
    
    
    
    // Tableview protocols
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sampleCategories.count // change to the fetched categories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as UITableViewCell!
    
        cell.textLabel?.text = sampleCategories[indexPath.row]
        cell.textLabel?.font = textField.text
        
    return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        <#code#>
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

