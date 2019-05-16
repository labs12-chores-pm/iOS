//
//  Item.swift
//  ShoppingList
//
//  Created by Nikita Thomas on 2/19/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

struct Task: Codable, Equatable {
    var description: String
    let categoryId: UUID
    var assigneeIds: [UUID]
    var dueDate: Date
    var notes: [Note]
    let identifier: UUID
    var isComplete: Bool
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.description == rhs.description &&
        lhs.assigneeIds == rhs.assigneeIds &&
        lhs.dueDate == rhs.dueDate &&
        lhs.isComplete == rhs.isComplete
    }
}
