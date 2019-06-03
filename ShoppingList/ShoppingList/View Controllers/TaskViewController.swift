//
//  TaskViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/17/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UserNotifications
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
        
        dayPickerView.delegate = self
        dayPickerView.dataSource = self
        
        searchResultsHeightConstraint.constant = 0
        
        guard let userController = userController, let currentUser = currentUser, let household = household else { fatalError() }
        
        self.hasAdminAccess = household.adminIds.contains(currentUser.identifier) ? true : false
        
        if let task = task, let userId = task.assigneeIds.first {
            
            self.dueDate = nil
            self.dueDate = task.dueDate
            
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
            DispatchQueue.main.async {
                self.updateViews()
            }
        }
        
        userController.fetchUsers(inHousehold: household) { (members, error) in
            if let error = error {
                print(error)
                return
            }
            self.householdMembers = members
        }
    }
    
    @IBAction func completeButtonWasTapped(_ sender: UIButton) {
        guard let taskController = taskController, let hasAdminAccess = hasAdminAccess else { return }
        
        guard let description = descriptionField.text else {
            completeButton.shake()
            displayMsg(title: "Description missing", msg: "Please add a description before creating a task.")
            return
        }
        
        let activityView = getActivityView()
        activityView.startAnimating()
        
        if hasAdminAccess {
            if let task = task {
                
                var ids: [UUID] = []
                if let assignee = assignee {
                    ids.append(assignee.identifier)
                }
                
                if task.recurrence == .once {
                    taskController.updateTask(task: task, description: description, assignIds: ids, dueDate: self.dueDate, isComplete: true, isPending: false)
                } else {
                    taskController.resetRecurringTask(task: task)
                }
                
            } else {
                guard let categoryId = category?.identifier, let householdId = household?.identifier else {
                    DispatchQueue.main.async {
                        activityView.stopAnimating()
                    }
                    return
                }
                
                var ids: [UUID] = []
                if let assignee = assignee {
                    ids.append(assignee.identifier)
                }
                
                taskController.createTask(description: description, categoryId: categoryId, assineeIds: ids, dueDate: self.dueDate ?? Date(), notes: [], isComplete: false, householdId: householdId, recurrence: self.recurrence ?? Recurrence(rawValue: 0)!)
            }
        } else {
            guard let task = task else {
                DispatchQueue.main.async {
                    activityView.stopAnimating()
                }
                return
            }
            taskController.updateTask(task: task, isPending: true)
            completeButton.setTitle("Pending Approval", for: .normal)
        }
        
        DispatchQueue.main.async {
            activityView.stopAnimating()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addNoteButtonWasTapped(_ sender: UIButton) {
        guard let task = task else {
            displayMsg(title: "No task found...", msg: "Please complete creating task before adding notes.")
            return
        }
        
        guard let text = noteTextField.text, !text.isEmpty else {
            displayMsg(title: "Note field missing", msg: "Please enter a note.")
            return
        }
        guard let memberId = currentUser?.identifier, let notesController = notesController else { return }
        let note = notesController.createNote(text: text, memberId: memberId, taskId: task.identifier)
        self.notes?.append(note)
        DispatchQueue.main.async {
            self.noteTextField.text = ""
        }
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        
            if let taskDescription = descriptionField.text, !taskDescription.trimmingCharacters(in: .whitespaces).isEmpty {
                
                print("This is the date from the Picker \(sender.date)")
                
                notificationHelper?.requestAuthorization { success in
                    if success {
                        self.notificationHelper?.scheduleTask(task: taskDescription, date: sender.date)
                    }
                }
            }
        
        guard let taskController = taskController, let task = task else { return }
        taskController.updateTask(task: task, dueDate: sender.date)
    }
    
    private func setNotes() {
        if let task = task, let notesController = notesController {
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
        
        _ = taskFormLabels.map { $0.font = AppearanceHelper.styleFont(with: .body, pointSize: 16) }
        
        descriptionField.font = AppearanceHelper.styleFont(with: .body, pointSize: 18)
            
        if let task = task {
            descriptionField.text = task.description
            
            self.dueDate = task.dueDate
            
            if let datePicker = datePicker {
                dayPickerView.selectRow(datePicker.getAMPMIndex(), inComponent: 3, animated: false)
            }
            
            recurrencePicker.selectRow(task.recurrence.rawValue, inComponent: 0, animated: true)
            noteTextField.isEnabled = true
            if task.isPending && !task.isComplete {
                completeButton.setTitle("Pending Approval", for: .normal)
            } else if task.isComplete {
                completeButton.setTitle("Task Complete!", for: .normal)
                completeButton.isEnabled = false
                descriptionField.isEnabled = false
                recurrencePicker.isUserInteractionEnabled = false
                assigneeSearch.isUserInteractionEnabled = false
            } else {
                completeButton.setTitle("Complete", for: .normal)
            }
        } else {
            noteTextField.isEnabled = false
            completeButton.setTitle("Create", for: .normal)
            recurrencePicker.selectRow(0, inComponent: 0, animated: true)
        }
        
        if hasAdminAccess == false {
            descriptionField.isEnabled = false
            recurrencePicker.isUserInteractionEnabled = false
            assigneeSearch.isUserInteractionEnabled = false
        }
        
        if searchResults == nil || searchResults!.isEmpty {
            assigneeSearchTableView.isHidden = true
            searchResultsHeightConstraint.constant = 0
        } else {
            assigneeSearchTableView.isHidden = false
            searchResultsHeightConstraint.constant = 120
        }
        
        self.setNotes()
    }
    
    private func setDateData() {
        guard let datePicker = datePicker else { return }
        
        dates = datePicker.dates
        datesStrings = datePicker.getDateStrings()
        hoursStrings = datePicker.getHourStrings()
        minutesStrings = datePicker.getMinutesStrings()
        
        DispatchQueue.main.async {
            self.updateViews()
            self.dayPickerView.reloadAllComponents()
            self.pickSetDate()
        }
    }
    
    private func pickSetDate() {
        
        guard let dates = dates, let setDate = datePicker?.setDate else { return }
        
        for (i, date) in dates.enumerated() {
            
            if date.removeTime() == setDate.removeTime() {
                self.dayPickerView.selectRow(i, inComponent: 0, animated: false)
                return
            }
        }
    }
    
    @IBOutlet weak var searchResultsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var assigneeSearchTableView: UITableView!
    @IBOutlet weak var completeButton: MonkeyButton!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var assigneeSearch: UISearchBar!
    @IBOutlet weak var recurrencePicker: UIPickerView!
    @IBOutlet weak var notesTableView: UITableView!
    
    @IBOutlet var taskFormLabels: [UILabel]!
    
    @IBOutlet weak var dayPickerView: UIPickerView!
    
    var task: Task? {
        didSet {
            datePicker = DatePicker(setDate: self.task?.dueDate)
        }
    }
    
    var datePicker: DatePicker? {
        didSet {
            setDateData()
        }
    }
    
    var dueDate: Date?
    
    var dates: [Date]?
    var datesStrings: [String]?
    var hoursStrings: [String]?
    var minutesStrings: [String]?
    
    var category: Category?
    var taskController: TaskController?
    var userController: UserController?
    var household: Household?
    
    var recurrence: Recurrence?
    
    var assignee: User? {
        didSet {
            DispatchQueue.main.async {
                self.assigneeSearch.text = self.assignee?.name
                self.searchResults = nil
            }
        }
    }
    
    var householdMembers: [User]?
    var currentUser: User?
    var notesController: NotesController?
    
    var hasAdminAccess: Bool?
    
    var notificationHelper : NotificationHelper?

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
                if self.notes?.count != 0 && self.notes?.count != nil {
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
        updateViews()
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
            cell.textLabel?.font = AppearanceHelper.styleFont(with: .body, pointSize: 14)
            cell.textLabel?.text = note.text
            cell.detailTextLabel?.text = note.date.string(style: .short, showTime: false)
            cell.detailTextLabel?.font = AppearanceHelper.styleFont(with: .body, pointSize: 14)
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
            defer { self.updateViews() }
            guard let selectedMember = householdMembers?[indexPath.row], let taskController = taskController else { return }
            
            self.assigneeSearch.text = selectedMember.name
            self.assignee = selectedMember
            self.searchResults = nil
            
            guard let task = task else { return }
            taskController.updateTask(task: task, description: task.description, assignIds: [selectedMember.identifier])
        }
    }
}

extension TaskViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        if pickerView == dayPickerView {
            return 4
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == dayPickerView {
            
            switch component {
            case 0:
                return self.datesStrings?.count ?? 0
            case 1:
                return self.hoursStrings?.count ?? 0
            case 2:
                return self.minutesStrings?.count ?? 0
            case 3:
                let symbolStrings = datePicker?.getAMPM()
                return symbolStrings?.count ?? 0
            default:
                return 0
            }
            
        } else {
            return recurrenceIntervals.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        
        if pickerView == recurrencePicker {
            pickerLabel.text = recurrenceIntervals[row]
        }
        
        if pickerView == dayPickerView {
            
            switch component {
            case 0:
                pickerLabel.text = self.datesStrings?[row]
            case 1:
                pickerLabel.text = self.hoursStrings?[row]
            case 2:
                pickerLabel.text = self.minutesStrings?[row]
            case 3:
                let symbolStrings = datePicker?.getAMPM()
                pickerLabel.text = symbolStrings?[row]
            default:
                break
            }
            
        }
        
        pickerLabel.font = AppearanceHelper.styleFont(with: .body, pointSize: 14)
        
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == recurrencePicker {
            
            let recurrence = Recurrence(rawValue: row)
            
            guard let taskController = taskController, let task = task else {
                self.recurrence = recurrence
                return
            }
            
            taskController.updateTask(task: task, description: task.description, recurrence: recurrence)
        }
        
        if pickerView == dayPickerView {
            
            guard let datePicker = datePicker, let dates = dates, let hoursStrings = hoursStrings, let minutesStrings = minutesStrings else { return }
            
            let baseDate = datePicker.setDate ?? datePicker.currentDate
            
            var dateComponents = Calendar.current.dateComponents([.month, .day, .hour, .minute, .second, .year], from: baseDate)
            
            switch component {
            case 0:
                let date = dates[row]
                dateComponents.month = Calendar.current.component(.month, from: date)
                dateComponents.day = Calendar.current.component(.day, from: date)
            case 1:
                let hour = Int(hoursStrings[row])!
                dateComponents.hour = datePicker.convertTo24HourTime(hour: hour)
            case 2:
                let minute = Int(minutesStrings[row])!
                dateComponents.minute = minute
            case 3:
                if row == 0 {
                    datePicker.isPM = false
                    
                    if dateComponents.hour! >= 12 {
                        dateComponents.hour! -= 12
                    }
                    
                    datePicker.newIsPM(isPM: false)
                    
                } else {
                    datePicker.isPM = true
                    
                    if dateComponents.hour! <= 12 {
                        dateComponents.hour! += 12
                    }
                    
                    datePicker.newIsPM(isPM: true)
                }
            default:
                break
            }
            
            let dateFromComponents = Calendar.current.date(from: dateComponents)
            
            self.dueDate = dateFromComponents
            
            guard let taskController = taskController, let task = task, let dueDate = dateFromComponents else {
                return
            }
            
            datePicker.setDate = dateFromComponents
            
            taskController.updateTask(task: task, dueDate: dueDate)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        if pickerView == dayPickerView {
            
            let half = pickerView.frame.width / 2
            
            switch component {
            case 0:
                return half
            case 1:
                return half / 3
            case 2:
                return half / 3
            case 3:
                return half / 3
            default:
                return 0
            }
        }
        
        return pickerView.frame.width
    }
}
