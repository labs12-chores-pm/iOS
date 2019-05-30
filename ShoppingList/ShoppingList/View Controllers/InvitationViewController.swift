//
//  InvitationViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/16/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class InvitationViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let household = household else { fatalError() }
        codeLabel.text = household.inviteCode
    }
    
    @IBAction func sendInviteButtonWasTapped(_ sender: UIButton) {
        guard let household = household,
        let householdController = householdController else { fatalError() }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        
        if let date = dateFormatter.date(from: household.inviteDate) {
            
            if date.timeIntervalSinceNow > 86400 {
                
                let invite = Invite()
                
                householdController.updateHousehold(household: household, memberIds: household.memberIds, adminIds: household.adminIds, categories: household.categories ?? [], invite: invite)
            }
        } else {
            let invite = Invite()
            
            householdController.updateHousehold(household: household, memberIds: household.memberIds, adminIds: household.adminIds, categories: household.categories ?? [], invite: invite)
        }
        
        let code = ["""
                    Hey there! \n
                    Use invite code \(household.inviteCode) to join \(household.name) on ChoreMonkey.
                    """]
        
        let ac = UIActivityViewController(activityItems: code, applicationActivities: nil)
        present(ac, animated: true, completion: nil)
    }
    
    @IBOutlet weak var codeLabel: UILabel!
    
    var household: Household?
    var householdController: HouseholdController?
}
