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
        
        if let currentUser = userController.currentUser {
            householdController.fetchHousehold(householdId: currentUser.currentHouseholdId) { (household, error) in
                if let error = error {
                    print(error)
                    return
                }
                self.household = household
            }
        }
    }
    
    private func updateViews() {
        guard let household = household else { return }
        householdNameLabel.text = household.name
    }
    
    
    @IBOutlet weak var householdNameLabel: UILabel!
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

