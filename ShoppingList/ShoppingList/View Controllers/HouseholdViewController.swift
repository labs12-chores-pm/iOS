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
        
        householdMemberTableView.rowHeight = UITableView.automaticDimension
        householdMemberTableView.estimatedRowHeight = 55
        
        if let tabBar = self.tabBarController as? TabViewViewController {
            
            self.taskController = tabBar.taskController
            self.householdController = tabBar.householdController
            self.userController = tabBar.userController
            self.currentUser = tabBar.currentUser
            self.notesController = tabBar.notesController
        } else {
            fatalError()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAndAssign()
        setDataSource()
    }
    
    @objc private func fetchAndAssign() {
        guard let currentUser = currentUser, let householdController = householdController,
            let userController = userController else { fatalError() }
        
        let activityView = getActivityView()
        activityView.startAnimating()
        
        userController.fetchUser(userId: currentUser.identifier) { (user, error) in
            if let error = error {
                print(error)
                DispatchQueue.main.async {
                    activityView.stopAnimating()
                }
                return
            }
            
            guard let user = user else {
                DispatchQueue.main.async {
                    activityView.stopAnimating()
                }
                return
            }
            
            householdController.fetchHousehold(householdId: user.currentHouseholdId) { (household, error) in
                if let error = error {
                    print(error)
                    DispatchQueue.main.async {
                        activityView.stopAnimating()
                    }
                    return
                }
                self.household = nil
                self.household = household
            }
            
            householdController.fetchHouseholds(user: user) { (households, error) in
                if let error = error {
                    print(error)
                    DispatchQueue.main.async {
                        activityView.stopAnimating()
                    }
                    return
                }
                self.pickerDataSource = nil
                self.pickerDataSource = households
                DispatchQueue.main.async {
                    activityView.stopAnimating()
                }
            }
        }
    }
    
    private func setDataSource() {
        let activityView = getActivityView()
        activityView.startAnimating()
        
        defer {
            DispatchQueue.main.async {
                self.updateViews()
                activityView.stopAnimating()
            }
        }
        
        self.messages = nil
        var messages: [Any] = []
        
        guard let taskController = taskController, let notesController = notesController else { fatalError() }
        guard let household = household else { return }
        
        taskController.fetchTasks(inHouseholdWith: household.identifier) { (tasks, error) in
            if let error = error {
                print(error)
                return
            }
            guard let tasks = tasks else { return }
            messages += tasks.filter({ $0.isPending == true })
            self.messages = messages
            for task in tasks {
                notesController.fetchNotes(taskId: task.identifier, completion: { (notes, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    guard let notes = notes else { return }
                    messages += notes
                    self.messages = messages
                    
                })
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
        
        if let messages = messages {
            if messages.count > UserDefaults.standard.integer(forKey: "MessageCount") {
                messagesBarButton.tintColor = .red
            } else {
                messagesBarButton.tintColor = .lightGray
            }
        }
        
        if let currentUser = currentUser {
            let admin = household.adminIds
            
            if !admin.contains(currentUser.identifier) && currentUser.identifier != household.creatorId {
                leaveButton.isHidden = true
                leaveButton.isEnabled = false
            } else if currentUser.identifier == household.creatorId {
                leaveButton.isEnabled = true
                leaveButton.isHidden = false
                leaveButton.setTitle("Delete Household", for: .normal)
            } else {
                leaveButton.isEnabled = true
                leaveButton.isHidden = false
            }
        }
    }
    
    @IBAction func leaveHouseholdButtonTapped(_ sender: UIButton) {
        
        guard let household = household, let householdController = householdController else { fatalError() }
        
        if let currentUser = currentUser {
            var members = household.memberIds
            var admins = household.adminIds
            
            guard admins.contains(currentUser.identifier) else {
                displayMsg(title: "Cannot leave household.", msg: "You must be an admin to remove users from a household.")
                return
            }
            
            if currentUser.identifier == household.creatorId {
                
                householdController.fetchHouseholds(user: currentUser) { (households, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    guard let households = households, let userController = self.userController else { return }
                    
                    let householdsMinusHousehold = households.filter({ $0.identifier != household.identifier })
                    guard let newHousehold = householdsMinusHousehold.first else { return }
                    
                    userController.updateUser(user: currentUser, currentHouseholdId: newHousehold.identifier, completion: { (error) in
                        if let error = error {
                            print(error)
                            return
                        }
                        
                        if households.count > 1 {
                            householdController.deleteHousehold(household: household) { (error) in
                                if let error = error {
                                    print(error)
                                    return
                                }
                                
                                self.fetchAndAssign()
                                self.setDataSource()
                                self.updateViews()
                            }
                        }
                    })
                }

            } else {
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
            let household = household, let householdController = householdController else { return }
            inviteVC.household = household
            inviteVC.householdController = householdController
        }
        
        if segue.identifier == "ShowMessages" {
            guard let messagesVC = segue.destination as? MessagesTableViewController,
            let userController = userController, let user = currentUser, let taskController = taskController,
            let householdController = householdController, let household = household, let notesController = notesController,
            let messages = messages
            else { return }
            
            messagesVC.userController = userController
            messagesVC.currentUser = user
            messagesVC.taskController = taskController
            messagesVC.householdController = householdController
            messagesVC.household = household
            messagesVC.notesController = notesController
            messagesVC.messages = messages
        }
    }
    
    @IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var messagesBarButton: UIBarButtonItem!
    @IBOutlet weak var householdPicker: UIPickerView!
    @IBOutlet weak var householdMemberTableView: UITableView!
    
    var messages: [Any]? {
        didSet {
            DispatchQueue.main.async {
                self.updateViews()
            }
        }
    }
    var taskController: TaskController?
    var householdController: HouseholdController?
    var userController: UserController?
    var notesController: NotesController?
    var household: Household? {
        didSet {
            DispatchQueue.main.async {
                self.householdMemberTableView.reloadData()
                self.updateViews()
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
        let userController = userController,
        let householdController = householdController else { return cell }
        
        let userId = household.memberIds[indexPath.row]
        
        userController.fetchUser(userId: userId) { (user, error) in
            if error != nil {
                fatalError()
            }
            
            guard let member = user else { fatalError() }
            userCell.member = member
        }
        
        userCell.userId = userId
        userCell.currentUser = currentUser
        
        userCell.household = household
        userCell.householdController = householdController
        
        return userCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let householdController = householdController, let household = household,
        let index = tableView.indexPathForSelectedRow, let currentUser = currentUser else { return }
        
        let userId = household.memberIds[index.row]
        
        guard userId != currentUser.identifier, household.adminIds.contains(currentUser.identifier) else { return }
        
        if editingStyle == .delete {
            let newMembers = household.memberIds.filter { $0 != userId }
            let newAdmin = household.adminIds.filter { $0 != userId }
            
            householdController.updateHousehold(household: household, memberIds: newMembers, adminIds: newAdmin, categories: household.categories ?? [])
            
            DispatchQueue.main.async {
                tableView.reloadData()
                self.updateViews()
            }
        }
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
        setDataSource()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource?[row].name
    }
}
