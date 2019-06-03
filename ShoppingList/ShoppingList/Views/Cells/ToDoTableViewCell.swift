//
//  ToDoTableViewCell.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 6/3/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class ToDoTableViewCell: UITableViewCell {
    
    private func updateViews() {
        guard let task = task, let category = category else { return }
        
        setAppearance()
        
        descriptionLabel.text = task.description.capitalized
        categoryLabel.text = category.name.capitalized
        dateLabel.text = task.dueDate.string(format: "E, MMM d")
        timeLabel.text = task.dueDate.string(format: "h:mm a")
    }
    
    private func setAppearance() {
        
        backgroundColor = AppearanceHelper.themeGray
        cellView.layer.cornerRadius = 18
        cellView.layer.masksToBounds = true
        cellView.layer.shadowOpacity = 0.5
        descriptionLabel.font = AppearanceHelper.styleFont(with: .body, pointSize: 18)
        categoryLabel.textColor = AppearanceHelper.midOrange
        categoryLabel.font = AppearanceHelper.styleFont(with: .body, pointSize: 16)
        dateLabel.font = AppearanceHelper.styleFont(with: .body, pointSize: 16)
        timeLabel.font = AppearanceHelper.styleFont(with: .body, pointSize: 16)
        
        dividerView.layer.cornerRadius = dividerView.frame.width / 2
        dividerView.layer.masksToBounds = true
    }
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!
    
    var category: Category? {
        didSet {
            updateViews()
        }
    }
    
    var task: Task? {
        didSet {
            updateViews()
        }
    }
}
