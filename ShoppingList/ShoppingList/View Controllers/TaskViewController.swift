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
        assigneeSearchTableView.dataSource = self
        assigneeSearchTableView.delegate = self
        recurrencePicker.delegate = self
        recurrencePicker.dataSource = self
        notesTableView.dataSource = self
        notesTableView.delegate = self
        assigneeSearchField.delegate = self
        dayPickerView.delegate = self
        dayPickerView.dataSource = self
        
        descriptionField.delegate = self
        noteTextField.delegate = self

        viewTapGestureRecognizer.delegate = self
        setGestureRecogizer()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setAppearance()
        
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
                        self.assigneeSearchField.text = user.name
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
            self.householdMembers = nil
            self.householdMembers = members
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setDateData()
    }
    
    private func editTask() {
        
        if hasAdminAccess == false {
            displayMsg(title: "Admin Permissions Needed", msg: "Admin permissions are needed to edit tasks.")
            return
        }
        
        
        guard let taskController = taskController, let task = task else {
            displayMsg(title: "Error saving changes", msg: "Something went wrong. Please try again later.")
            return
        }
        
        var assigneeIds: [UUID] = []
        
        if let assignee = assignee {
            assigneeIds.append(assignee.identifier)
        } else {
            
            if let assigneeSearch = assigneeSearchField.text {
                
                if let user = checkForMatchingMembersWithString(assigneeSearch) {
                    assigneeIds.append(user.identifier)
                }
            }
        }
        
        taskController.updateTask(task: task, description: descriptionField.text, assignIds: assigneeIds, dueDate: dueDate, recurrence: recurrence)
        
        DispatchQueue.main.async {
            self.updateButtonViews()
        }
        
        taskWasChanged = false
    }
    
    private func checkForMatchingMembersWithString(_ string: String) -> User? {
        guard let householdMembers = householdMembers else { return nil }
        
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercaseString = trimmedString.lowercased()
        
        let usersMatchingString = householdMembers.filter { $0.name.lowercased() == lowercaseString }
        
        return usersMatchingString.first
    }
    
    
    @IBAction func completeButtonWasTapped(_ sender: UIButton) {
        if taskWasChanged && task != nil {
            editTask()
            return
        }
        
        guard let taskController = taskController, let hasAdminAccess = hasAdminAccess, let currentUser = currentUser else { return }
        
        guard let description = descriptionField.text else {
            completeButton.shake()
            displayMsg(title: "Description missing", msg: "Please add a description before creating a task.")
            return
        }
        
        let activityView = getActivityView()
        activityView.startAnimating()
        
        let assignee: [UUID] = self.assignee != nil ? [self.assignee!.identifier] : []
        
        let userIsAssignee = currentUser.identifier == assignee.first
        
        
        if let task = task {
            
            switch hasAdminAccess {
                
            case true:
                
                if !task.isPending && !userIsAssignee {
                    
                    displayMsg(title: "Complete?", msg: """
                    It looks like you are not assigned to
                    this task, and that it isn't pending completion. \n
                    Are you sure that you want to mark it as complete?
                    """, numberOfButtons: 2) { (complete) in
                        
                        guard let complete = complete, complete == true else {
                            DispatchQueue.main.async {
                                activityView.stopAnimating()
                            }
                            return
                        }
                        
                        if task.recurrence == .once {
                            taskController.updateTask(task: task, description: description, assignIds: assignee, dueDate: self.dueDate, isComplete: true, isPending: false)
                        } else {
                            taskController.resetRecurringTask(task: task)
                        }
                        
                        DispatchQueue.main.async {
                            activityView.stopAnimating()
                        }
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                } else {
                    
                    if task.recurrence == .once {
                        taskController.updateTask(task: task, description: description, assignIds: assignee, dueDate: self.dueDate, isComplete: true, isPending: false)
                    } else {
                        taskController.resetRecurringTask(task: task)
                    }
                    
                    DispatchQueue.main.async {
                        activityView.stopAnimating()
                    }
                    self.navigationController?.popViewController(animated: true)
                }
                
                
            case false:
                
                taskController.updateTask(task: task, isPending: true)
                completeButton.setTitle("Pending Approval", for: .normal)
                
                DispatchQueue.main.async {
                    activityView.stopAnimating()
                }
                self.navigationController?.popViewController(animated: true)
            }
            
        } else {
            
            guard let categoryId = category?.identifier, let householdId = household?.identifier else {
                DispatchQueue.main.async {
                    activityView.stopAnimating()
                }
                return
            }

            self.task = taskController.createTask(description: description, categoryId: categoryId, assineeIds: assignee, dueDate: self.dueDate ?? Date(), isComplete: false, householdId: householdId, recurrence: self.recurrence ?? Recurrence(rawValue: 0)!)
            
            DispatchQueue.main.async {
                activityView.stopAnimating()
            }
            self.navigationController?.popViewController(animated: true)
        }
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
        guard let memberId = currentUser?.identifier, let notesController = notesController, let name = currentUser?.name else { return }
        let note = notesController.createNote(text: text, memberId: memberId, taskId: task.identifier, senderName: name)
        self.notes?.append(note)
        DispatchQueue.main.async {
            self.noteTextField.text = ""
        }
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
            
        if let task = task {
            
            descriptionField.text = task.description
            
            let recurrenceValue = recurrence == nil ? task.recurrence.rawValue : recurrence?.rawValue
            recurrencePicker.selectRow(recurrenceValue!, inComponent: 0, animated: false)
            
            
            if let amPM = datePicker?.getAMPMIndex() {
                dayPickerView.selectRow(amPM, inComponent: 3, animated: false)
            }
        }
        
        updateButtonViews()
        
        if hasAdminAccess == false {
            descriptionField.isEnabled = false
            recurrencePicker.isUserInteractionEnabled = false
            assigneeSearchField.isUserInteractionEnabled = false
        }
        
        self.setNotes()
    }
    
    private func updateButtonViews() {
        guard let task = task else {
            completeButton.setTitle("Create", for: .normal)
            completeButton.backgroundColor = AppearanceHelper.teal
            return
        }
        
        if task.isPending && !task.isComplete {
            completeButton.setTitle("Pending Approval", for: .normal)
            completeButton.backgroundColor = AppearanceHelper.lightOrange
        } else if task.isComplete {
            completeButton.setTitle("Task Complete!", for: .normal)
            completeButton.isEnabled = false
            descriptionField.isEnabled = false
            recurrencePicker.isUserInteractionEnabled = false
            assigneeSearchField.isEnabled = false
            completeButton.backgroundColor = AppearanceHelper.themeGray
        } else {
            if taskWasChanged {
                completeButton.setTitle("Save Changes", for: .normal)
                completeButton.backgroundColor = AppearanceHelper.teal
            } else {
                completeButton.setTitle("Mark Task Completed", for: .normal)
                completeButton.backgroundColor = AppearanceHelper.yellow
            }
        }
    }
    
    private func setAppearance() {
        guard isViewLoaded else { return }
        
        assigneeSearchTableView.isHidden = true
        assigneeSearchTableView.alpha = 0
        
        taskScrollView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        _ = taskFormLabels.map { $0.font = AppearanceHelper.styleFont(with: .body, pointSize: 16) }
        descriptionField.font = AppearanceHelper.styleFont(with: .body, pointSize: 16)
        assigneeSearchField.font = AppearanceHelper.styleFont(with: .body, pointSize: 16)
        noteTextField.font = AppearanceHelper.styleFont(with: .body, pointSize: 16)
    }
    
    private func updateSearchViews() {
        guard let searchResults = searchResults else {
            hideSearchResultsTableView()
            return
        }
        
        if searchResults.count > 0 {
            showSearchResultsTableView()
        } else {
            hideSearchResultsTableView()
        }
        
        self.assigneeSearchTableView.reloadData()
    }
    
    private func showSearchResultsTableView() {
        
        self.assigneeSearchTableView.isHidden = false
        
        viewWillLayoutSubviews()
        
        UIView.animate(withDuration: 0.2) {
            self.assigneeSearchTableView.alpha = 1
        }
    }
    
    private func hideSearchResultsTableView() {
        
        self.assigneeSearchTableView.isHidden = true
        
        viewWillLayoutSubviews()
        
        UIView.animate(withDuration: 0.2) {
            self.assigneeSearchTableView.alpha = 0
        }
    }
    
    private func setDateData() {
        guard let datePicker = datePicker, dayPickerView != nil else { return }
        
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
    
    @IBOutlet weak var assigneeSearchField: BlueField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var assigneeSearchTableView: UITableView!
    @IBOutlet weak var completeButton: MonkeyButton!
    @IBOutlet weak var descriptionField: UITextField!
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
                self.assigneeSearchField.text = self.assignee?.name
                self.searchResults = []
                self.updateSearchViews()
            }
        }
    }
    
    var householdMembers: [User]?
    var currentUser: User?
    var notesController: NotesController?
    
    var hasAdminAccess: Bool?
    var inEditingMode: Bool = false
    
    var notificationHelper : NotificationHelper?

    @IBOutlet weak var taskScrollView: UIScrollView!
    
    var searchResults: [User]? {
        didSet {
            DispatchQueue.main.async {
                self.updateSearchViews()
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
    
    var viewTapGestureRecognizer = UITapGestureRecognizer()
    
    var textFieldBeingEdited: UITextField?
    
    var taskWasChanged: Bool = false
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
            guard let searchResults = searchResults, searchResults.count > 0 else { return cell }
            let result = searchResults[indexPath.row]
            cell.textLabel?.text = result.name
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
            guard let notes = notes else { return cell }
            let note = notes[indexPath.row]
            cell.textLabel?.font = AppearanceHelper.styleFont(with: .body, pointSize: 14)
            cell.textLabel?.text = note.text
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == assigneeSearchTableView {
            guard let selectedMember = searchResults?[indexPath.row], let taskController = taskController else { return }
            
            self.assigneeSearchField.text = selectedMember.name
            self.assignee = selectedMember
            self.searchResults = []
            self.updateSearchViews()
            
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
        
        taskWasChanged = true
        
        if pickerView == recurrencePicker {
            
            let recurrence = Recurrence(rawValue: row)
            
            guard let taskController = taskController, let task = task else {
                self.recurrence = recurrence
                return
            }
            
            taskController.updateTask(task: task, description: task.description, recurrence: recurrence)
            self.recurrence = recurrence
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
            
            guard let taskController = taskController, let task = task, let dueDate = dateFromComponents else {
                return
            }
            
            self.dueDate = dueDate
            datePicker.setDate = dueDate
            taskController.updateTask(task: task, dueDate: dueDate)
        }
        
        updateButtonViews()
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

extension TaskViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        searchHouseholdMembers(textField)
        taskWasChanged = true
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textFieldBeingEdited = nil
        textFieldBeingEdited = textField
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateButtonViews()
        textFieldBeingEdited = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        keyboardWillHide()
        textFieldBeingEdited = nil
        return true
    }
    
    private func searchHouseholdMembers(_ textField: UITextField) {
        guard let householdMembers = householdMembers, let text = textField.text, !text.isEmpty else { return }
        let searchResults = householdMembers.filter { $0.name.lowercased().contains(text.lowercased()) }
        self.searchResults = searchResults
        updateSearchViews()
    }
    
    // Keyboard Notification
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if textFieldBeingEdited == noteTextField {
            if let keyboardFrame: CGRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect, keyboardFrame.height != 0 {
                taskScrollView.contentInset.bottom = keyboardFrame.height
                taskScrollView.scrollIndicatorInsets = taskScrollView.contentInset
            }
        }
    }
    
    @objc func keyboardWillHide() {
        if textFieldBeingEdited == noteTextField {
            taskScrollView.contentInset.bottom = 0
            taskScrollView.scrollIndicatorInsets = taskScrollView.contentInset
        }
    }
}

extension TaskViewController: UIGestureRecognizerDelegate {
    
    private func setGestureRecogizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewWasTapped))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.cancelsTouchesInView = false
        viewTapGestureRecognizer = tapRecognizer
        view.addGestureRecognizer(viewTapGestureRecognizer)
    }

    @objc func viewWasTapped() {
        if let textField = textFieldBeingEdited {
            textField.resignFirstResponder()
            textFieldBeingEdited = nil
            keyboardWillHide()
        }
    }
}
