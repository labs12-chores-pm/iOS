//
//  AddCategoryViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/17/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class AddCategoryViewController: UIViewController {
    
    @IBAction func createCategoryButtonWasTapped(_ sender: UIButton) {
        guard let categoryController = categoryController, let user = currentUser else { fatalError() }
        guard let name = categoryNameField.text else {
            createCategoryButton.shake()
            displayMsg(title: "Missing field", msg: "Please add a category name")
            return
        }
        
        categoryController.createCategory(householdId: user.currentHouseholdId, name: name)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var categoryNameField: UITextField!
    @IBOutlet weak var createCategoryButton: MonkeyButton!
    
    var categoryController: CategoryController?
    var currentUser: User?
}
