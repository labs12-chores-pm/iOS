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
        
        fetchCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchCategories), name: NSNotification.Name("addedCategory"), object: nil)
    }
    
    @objc func fetchCategories() {
        // Test Code
        let user = userController.currentUser
        let householdId = user.currentHouseholdId
        categoryController.fetchCategories(householdId: householdId) { (categories, error) in
            if let error = error {
                print(error)
                return
            }
            self.categories = categories
        }
        
        //        if let user = userController.currentUser {
        //            let householdId = user.currentHouseholdId
        //            categoryController.fetchCategories(householdId: householdId) { (categories, error) in
        //                if let error = error {
        //                    print(error)
        //                    return
        //                }
        //                self.categories = categories
        //            }
        //        }
    }
    
    func refresh() {
        categoriesTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddCategory" {
            guard let destinationVC = segue.destination as? AddCategoryViewController else { return }
            
            destinationVC.categoryController = categoryController
            destinationVC.userController = userController
        }
        
        if segue.identifier == "ShowTasks" {
            guard let destinationVC = segue.destination as? TasksTableViewController,
            let index = categoriesTableView.indexPathForSelectedRow,
            let categories = categories
            else { return }
            
            let category = categories[index.row]
            
            destinationVC.category = category
        }
    }
    
    @IBOutlet weak var addCategoryButton: UIButton!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var categoriesTableView: UITableView!
    
    let userController = UserController()
    let categoryController = CategoryController()
    var categories: [Category]? {
        didSet {
            DispatchQueue.main.async {
                self.categoriesTableView.reloadData()
            }
        }
    }
}

extension MainCategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = categoriesTableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        if let categories = categories {
            cell.textLabel?.text = categories[indexPath.row].name
        }
        return cell
    }
}
