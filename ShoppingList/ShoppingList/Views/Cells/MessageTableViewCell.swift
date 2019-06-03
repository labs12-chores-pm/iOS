//
//  MessageTableViewCell.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 6/3/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setAppearance()
    }
    
    private func setAppearance() {
        
        backgroundColor = AppearanceHelper.themeGray
        selectionStyle = .none
        messageView.backgroundColor = .white
        messageView.layer.cornerRadius = 12
        
        messageTextLabel.font = AppearanceHelper.styleFont(with: .body, pointSize: 16)
        
        timeLabel.font = AppearanceHelper.styleFont(with: .body, pointSize: 12)
        timeLabel.textColor = .darkGray
    }
    
    private func updateViews() {
        
        let timeStringFormat = "EEEE, MMM d, h:mm a"
        
        if let taskMessage = message as? Task {
            isNote = false
            
            messageTextLabel.text = "Pending completion: \(taskMessage.description)"
            timeLabel.text = "Due: \(taskMessage.dueDate.string(format: timeStringFormat))"
        }
        
        if let noteMessage = message as? Note {
            isNote = true
            
            messageTextLabel.text = noteMessage.text
            timeLabel.text = "\(noteMessage.senderName.capitalized), \(noteMessage.date.string(format: timeStringFormat))"
        }
    }
    
    private func changeToNoteConstraints() {
        messageView.translatesAutoresizingMaskIntoConstraints = false
        if let isNote = isNote, isNote {
            leadingConstraint.constant = 20
            trailingConstraint.constant = 60
        } else {
            leadingConstraint.constant = 60
            trailingConstraint.constant = 20
        }
        messageView.layoutIfNeeded()
    }

    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var message: Any? {
        didSet {
            updateViews()
        }
    }
    
    var isNote: Bool? {
        didSet {
            changeToNoteConstraints()
        }
    }
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
}
