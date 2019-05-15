//
//  HouseholdUserTableViewCell.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/15/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class HouseholdUserTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        userRolePickerView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var userRolePickerView: UIPickerView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userTasksTableView: UITableView!
    
    let roles: [Roles] = [.admin, .nonAdmin]
}

extension HouseholdUserTableViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return roles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let role = roles[row]
        
        switch role {
            
        }
    }
}
