//
//  TabViewViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/16/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift

class TabViewViewController: UITabBarController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBar.tintColor = AppearanceHelper.midOrange
        self.tabBar.barTintColor = AppearanceHelper.themeGray
        self.tabBar.unselectedItemTintColor = .gray
        
        self.tabBar.itemPositioning = .centered
        
        Auth.auth().addIDTokenDidChangeListener { (auth, user) in
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(currentHouseholdWasChanged), name: Notification.Name(.householdChange), object: nil)
    }
    
    @objc private func currentHouseholdWasChanged() {
        guard let userController = userController, let currentUser = currentUser else { return }
        userController.fetchUser(userId: currentUser.identifier) { (user, error) in
            if let error = error {
                print(error)
                return
            }
            guard let user = user else { return }
            self.currentUser = user
        }
    }
    
    var authResponse: AuthDataResult?
    var userController: UserController?
    var currentUser: User?
    var householdController: HouseholdController?
    var keychain: KeychainSwift?
    let notesController = NotesController()
    let taskController = TaskController()
    let categoryController = CategoryController()
    let notificationHelper = NotificationHelper()
}
