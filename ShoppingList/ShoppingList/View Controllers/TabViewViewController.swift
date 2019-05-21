//
//  TabViewViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/16/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit
import Firebase

class TabViewViewController: UITabBarController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Auth.auth().addIDTokenDidChangeListener { (auth, user) in
            
        }
    }
    
    var userController: UserController?
    var currentUser: User?
    var householdController: HouseholdController?
    let taskController = TaskController()
    let categoryController = CategoryController()
}
