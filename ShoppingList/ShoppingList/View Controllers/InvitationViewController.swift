//
//  InvitationViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/16/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class InvitationViewController: UIViewController {
    
    @IBAction func sendInviteButtonWasTapped(_ sender: UIButton) {
        guard let household = household,
            let name = nameField.text,
            let email = emailField.text else { return }
        
        
        inviteController.sendInvite(household: household, name: name, email: email)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!

    var household: Household?
    let inviteController = InviteController()
}
