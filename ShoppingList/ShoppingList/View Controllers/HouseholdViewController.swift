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
        householdPicker.delegate = self
        householdPicker.dataSource = self
        
        if let tabBar = self.tabBarController as? TabViewViewController {
            
            self.householdController = tabBar.householdController
            self.userController = tabBar.userController
            self.currentUser = tabBar.currentUser
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(fetchAndAssign), name: NSNotification.Name("newHousehold"), object: self)
    }
    
    @objc private func fetchAndAssign() {
        guard let currentUser = currentUser, let householdController = householdController else { return }
        
        householdController.fetchHousehold(householdId: currentUser.currentHouseholdId) { (household, error) in
            if let error = error {
                print(error)
                return
            }
            self.household = household
        }
        
        householdController.fetchHouseholds(user: currentUser) { (households, error) in
            if let error = error {
                print(error)
                return
            }
            self.pickerDataSource = households
        }
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
        if segue.identifier == "PopCreateHousehold" {
            guard let createVC = segue.destination as? CreateHouseholdViewController else { return }
            createVC.householdController = self.householdController
            createVC.userController = self.userController
        }
    }
    
    @IBOutlet weak var householdPicker: UIPickerView!
    @IBOutlet weak var householdMemberTableView: UITableView!
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
        let household = household, let currentUser = currentUser else { return cell }
        
        let userId = household.memberIds[indexPath.row]
        userCell.userId = userId
        
        userCell.currentUser = currentUser
        
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
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource?[row].name
    }
}
