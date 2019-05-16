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
        
        if let currentUser = userController.currentUser {
           
            self.currentUser = currentUser
            
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
    }
    
    private func updateViews() {
//        guard let household = household else { return }
    }
    
    @IBOutlet weak var householdPicker: UIPickerView!
    @IBOutlet weak var householdMemberTableView: UITableView!
    let householdController = HouseholdController()
    var userController = UserController()
    var household: Household? {
        didSet {
            DispatchQueue.main.async {
                self.householdMemberTableView.reloadData()
                self.updateViews()
            }
        }
    }
    
    var currentUser: User?
    
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
        let household = household else { return cell }
        
        let userId = household.memberIds[indexPath.row]
        userCell.userId = userId
        
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
        guard let currentUser = currentUser else { return }
        
        let household = pickerDataSource?[row].identifier
        
        userController.updateUser(user: currentUser, currentHouseholdId: household)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource?[row].name
    }
}
