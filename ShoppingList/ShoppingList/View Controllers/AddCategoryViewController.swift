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
        guard let categoryController = categoryController,
            let userController = userController,
            let name = categoryNameField.text else { return }
        
        let user = userController.currentUser
        categoryController.createCategory(householdId: user.currentHouseholdId, name: name)
        
        NotificationCenter.default.post(name: NSNotification.Name("addedCategory"), object: nil)
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var categoryNameField: UITextField!
    var categoryController: CategoryController?
    var userController: UserController?
}
