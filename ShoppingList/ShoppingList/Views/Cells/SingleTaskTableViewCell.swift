//
//  SingleTaskTableViewCell.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 6/4/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class SingleTaskTableViewCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        getAssigneeName()
        setAppearance()
        updateViews()
    }

    private func getAssigneeName() {
        guard let userController = userController, let task = task,
            let assigneeId = task.assigneeIds.first else {
                return
        }
        
        if let categoryController = categoryController {
            
            categoryController.fetchCategory(identifier: task.categoryId) { (category, error) in
                if let error = error {
                    print(error)
                }
                
                if let category = category {
                    self.category = category
                    return
                }
            }
        }
        
        userController.fetchUser(userId: assigneeId) { (user, error) in
            if let error = error {
                print(error)
                
                DispatchQueue.main.async {
                    self.updateViews()
                }
                return
            }
            
            guard let user = user else {
                DispatchQueue.main.async {
                    self.updateViews()
                }
                return
            }
            
            self.assignee = user
        }
    }
    
    private func updateViews() {
        guard let task = task else { return }
        
        descriptionLabel.text = task.description.capitalized
        dueDateLabel.text = task.dueDate.string(format: "E, MMM d")
        timeLabel.text = task.dueDate.string(format: "h:mm a")
        
        if let category = category {
            assigneeLabel.text = category.name.capitalized
        } else {
            
            if let assignee = assignee {
                assigneeLabel.text = assignee.name.capitalized
            } else {
                assigneeLabel.text = "Task is not assigned"
            }
        }
    }
    
    private func setAppearance() {
        
        backgroundColor = AppearanceHelper.themeGray
        cellView.layer.cornerRadius = 18
        cellView.layer.masksToBounds = true
        cellView.layer.shadowOpacity = 0.5
        descriptionLabel.font = AppearanceHelper.styleFont(with: .body, pointSize: 18)
        assigneeLabel.textColor = AppearanceHelper.midOrange
        assigneeLabel.font = AppearanceHelper.styleFont(with: .body, pointSize: 16)
        dueDateLabel.font = AppearanceHelper.styleFont(with: .body, pointSize: 16)
        timeLabel.font = AppearanceHelper.styleFont(with: .body, pointSize: 16)
        
        dividerLabel.layer.cornerRadius = dividerLabel.frame.width / 2
        dividerLabel.layer.masksToBounds = true
        
        selectionStyle = .none
    }
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var assigneeLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dividerLabel: UIView!
    @IBOutlet weak var cellView: UIView!
    
    var userController: UserController?
    var categoryController: CategoryController?
    
    var category: Category? {
        didSet {
            DispatchQueue.main.async {
                self.updateViews()
            }
        }
    }
    
    var assignee: User? {
        didSet {
            DispatchQueue.main.async {
                self.updateViews()
            }
        }
    }
    
    var task: Task?
}
