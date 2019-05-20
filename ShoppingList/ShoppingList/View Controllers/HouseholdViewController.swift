//
//  HouseholdViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/14/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class HouseholdViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        householdMemberTableView.delegate = self
        householdMemberTableView.dataSource = self
        householdPicker.delegate = self
        householdPicker.dataSource = self
        
        if let tabBar = self.tabBarController as? TabViewViewController {
            
            self.taskController = tabBar.taskController
            self.householdController = tabBar.householdController
            self.userController = tabBar.userController
            self.currentUser = tabBar.currentUser
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAndAssign()
    }
    
    @objc private func fetchAndAssign() {
        guard let currentUser = currentUser, let householdController = householdController,
            let userController = userController else { return }
        
        userController.fetchUser(userId: currentUser.identifier) { (user, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let user = user else { return }
            
            householdController.fetchHousehold(householdId: user.currentHouseholdId) { (household, error) in
                if let error = error {
                    print(error)
                    return
                }
                self.household = household
            }
            
            householdController.fetchHouseholds(user: user) { (households, error) in
                if let error = error {
                    print(error)
                    return
                }
                self.pickerDataSource = households
            }
        }
    }
    
    private func updateViews() {
        guard let household = household, let pickerDataSource = pickerDataSource else { return }
        
        var index = 0
    
        for (sourceIndex, sourceHousehold) in pickerDataSource.enumerated() {
            if household.identifier == sourceHousehold.identifier {
                index = sourceIndex
            }
        }
        
        householdPicker.selectRow(index, inComponent: 0, animated: true)
        householdMemberTableView.reloadData()
    }
    
    @IBAction func leaveHouseholdButtonTapped(_ sender: UIButton) {
        
        guard let household = household, let householdController = householdController else { return }
        
        if let currentUser = currentUser {
            var members = household.memberIds
            var admins = household.adminIds
            
            for (index, id) in members.enumerated() {
                if id == currentUser.identifier {
                    members.remove(at: index)
                }
            }
            
            for (index, id) in admins.enumerated() {
                if id == currentUser.identifier {
                    admins.remove(at: index)
                }
            }
            householdController.updateHousehold(household: household, memberIds: members, adminIds: admins, categories: [])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCreateHousehold" {
            guard let createVC = segue.destination as? CreateHouseholdViewController,
            let user = self.currentUser else { return }
            createVC.householdController = self.householdController
            createVC.userController = self.userController
            createVC.currentUser = user
        }
        
        if segue.identifier == "ShowInvite" {
            guard let inviteVC = segue.destination as? InvitationViewController,
            let household = household else { return }
            inviteVC.household = household
        }
    }
    
    @IBOutlet weak var householdPicker: UIPickerView!
    @IBOutlet weak var householdMemberTableView: UITableView!
    
    var taskController: TaskController?
    var householdController: HouseholdController?
    var userController: UserController?
    var household: Household? {
        didSet {
            DispatchQueue.main.async {
                self.householdMemberTableView.reloadData()
            }
        }
    }
    
    var currentUser: User? {
        didSet {
            fetchAndAssign()
        }
    }
    
    var pickerDataSource: [Household]? {
        didSet {
            DispatchQueue.main.async {
                self.householdPicker.reloadAllComponents()
                self.updateViews()
            }
        }
    }
}

extension HouseholdViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return household?.memberIds.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath)
        guard let userCell = cell as? HouseholdUserTableViewCell,
        let household = household, let currentUser = currentUser,
        let userController = userController, let taskController = taskController,
        let householdController = householdController else { return cell }
        
        let userId = household.memberIds[indexPath.row]
        userCell.userId = userId
        userCell.currentUser = currentUser
        
        userCell.household = household
        userCell.userController = userController
        userCell.taskController = taskController
        userCell.householdController = householdController
        
        return userCell
    }
}

extension HouseholdViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let currentUser = currentUser, let userController = userController else { return }
        let household = pickerDataSource?[row].identifier
        userController.updateUser(user: currentUser, currentHouseholdId: household)
        fetchAndAssign()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource?[row].name
    }
}
