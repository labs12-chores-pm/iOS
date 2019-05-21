//
//  TaskViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/17/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class TaskViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assigneeSearch.delegate = self
        assigneeSearchTableView.dataSource = self
        assigneeSearchTableView.delegate = self
        recurrencePicker.delegate = self
        recurrencePicker.dataSource = self
        notesTableView.dataSource = self
        notesTableView.delegate = self
        
        guard let userController = userController else { return }
        
        if let task = task, let userId = task.assigneeIds.first {
            
            userController.fetchUser(userId: userId) { (user, error) in
                if let error = error {
                    print(error)
                    return
                }
                if let user = user {
                    self.assignee = user
                    DispatchQueue.main.async {
                        self.assigneeSearch.text = user.name
                    }
                }
            }
        } else {
            updateViews()
        }
        
        if let household = household {
            userController.fetchUsers(inHousehold: household) { (members, error) in
                if let error = error {
                    print(error)
                    return
                }
                self.householdMembers = members
            }
        }
    }
    
    @IBAction func completeButtonWasTapped(_ sender: UIButton) {
        guard let description = descriptionField.text,
            let taskController = taskController, let household = household, let currentUser = currentUser else { return }
        
        if household.adminIds.contains(currentUser.identifier) {
            if let task = task {
                
                var assigneeId: [UUID]!
                if let assignee = assignee {
                    assigneeId = [assignee.identifier]
                } else {
                    assigneeId = []
                }
                
                taskController.updateTask(task: task, description: description, assignIds: assigneeId, dueDate: dueDatePicker.date)
            } else {
                guard let categoryId = category?.identifier else { return }
                
                var assigneeId: [UUID]!
                if let assignee = assignee {
                    assigneeId = [assignee.identifier]
                } else {
                    assigneeId = []
                }
                
                taskController.createTask(description: description, categoryId: categoryId, assineeIds: assigneeId, dueDate: dueDatePicker.date, notes: [], isComplete: false)
            }
        } else {
            guard let task = task else { return }
            taskController.updateTask(task: task, isPending: true)
            completeButton.setTitle("Pending Approval", for: .normal)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addNoteButtonWasTapped(_ sender: UIButton) {
        guard let text = noteTextField.text, let memberId = currentUser?.identifier, let task = task else { return }
        let note = notesController.createNote(text: text, memberId: memberId, taskId: task.identifier)
        self.notes?.append(note)
        DispatchQueue.main.async {
            self.noteTextField.text = ""
        }
    }
    
    private func setNotes() {
        if let task = task {
            notesController.fetchNotes(taskId: task.identifier) { (notes, error) in
                if let error = error {
                    print(error)
                    return
                }
                self.notes = notes
            }
        }
    }
    
    private func updateViews() {
        guard isViewLoaded else { return }
        
        taskScrollView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        if let task = task {
            descriptionField.text = task.description
            dueDatePicker.date = task.dueDate
            recurrencePicker.selectRow(task.recurrence.rawValue, inComponent: 0, animated: true)
            if task.isPending {
                completeButton.setTitle("Pending Approval", for: .normal)
            } else {
                completeButton.setTitle("Complete", for: .normal)
            }
        } else {
            completeButton.setTitle("Create", for: .normal)
            recurrencePicker.selectRow(0, inComponent: 0, animated: true)
        }
        
        self.setNotes()
    }
    
    
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var assigneeSearchTableView: UITableView!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var assigneeSearch: UISearchBar!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var recurrencePicker: UIPickerView!
    @IBOutlet weak var notesTableView: UITableView!
    
    var task: Task? {
        didSet {
            updateViews()
        }
    }
    
    var category: Category?
    var taskController: TaskController?
    var userController: UserController?
    var household: Household?
    
    var assignee: User? {
        didSet {
            DispatchQueue.main.async {
                self.assigneeSearch.text = self.assignee?.name
                self.searchResults = []
            }
        }
    }
    
    var householdMembers: [User]?
    var currentUser: User?
    let notesController = NotesController()

    @IBOutlet weak var taskScrollView: UIScrollView!
    
    var searchResults: [User]? {
        didSet {
            self.assigneeSearchTableView.reloadData()
            DispatchQueue.main.async {
                self.updateViews()
                self.viewDidLayoutSubviews()
            }
        }
    }
    
    var notes: [Note]? {
        didSet {
            DispatchQueue.main.async {
                self.notesTableView.reloadData()
                if self.notes?.count != 0 {
                    let last = self.notes!.count - 1
                    self.notesTableView.scrollToRow(at: IndexPath(row: last, section: 0), at: .bottom, animated: true)
                }
            }
        }
    }
    
    let recurrenceIntervals = ["Once", "Daily", "Weekly", "Monthly", "Yearly"]
}

extension TaskViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let householdMembers = householdMembers else { return }
        let searchResults = householdMembers.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        self.searchResults = searchResults
    }
}

extension TaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == assigneeSearchTableView {
            return searchResults?.count ?? 0
        } else {
            return notes?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == assigneeSearchTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AssigneeSearchCell", for: indexPath)
            guard let searchResults = searchResults else { return cell }
            let result = searchResults[indexPath.row]
            cell.textLabel?.text = result.name
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
            guard let notes = notes else { return cell }
            let note = notes[indexPath.row]
            cell.textLabel?.text = note.text
            cell.detailTextLabel?.text = note.date.dateToString()
            return cell
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let frame = assigneeSearchTableView.frame
        assigneeSearchTableView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: assigneeSearchTableView.contentSize.height)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == assigneeSearchTableView {
            guard let selectedMember = householdMembers?[indexPath.row], let taskController = taskController, let task = task else { return }
            self.assigneeSearch.text = selectedMember.name
            taskController.updateTask(task: task, description: task.description, assignIds: [selectedMember.identifier])
            self.assignee = selectedMember
        }
    }
}

extension TaskViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return recurrenceIntervals.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return recurrenceIntervals[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == recurrencePicker {
            guard let taskController = taskController, let task = task else { return }
            taskController.updateTask(task: task, description: task.description, recurrence: Recurrence(rawValue: row))
        }
    }
}
