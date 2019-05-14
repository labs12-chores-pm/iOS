//
//  Item.swift
//  ShoppingList
//
//  Created by Nikita Thomas on 2/19/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import CoreData

extension Task {
    
    convenience init(description: String, identifier: UUID = UUID(), categoryId: UUID, assigneeIds: [UUID], dueDate: Date, notes: [UUID], isComplete: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.descriptionText = description
        self.categoryId = categoryId
        self.assigneeIds = assigneeIds
        self.dueDate = dueDate
        self.notes = notes
        self.identifier = identifier
        self.isComplete = isComplete
    }
    
    convenience init(taskRepresentation: TaskRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(description: taskRepresentation.description, identifier: taskRepresentation.identifier, categoryId: taskRepresentation.categoryId, assigneeIds: taskRepresentation.assigneeIds, dueDate: taskRepresentation.dueDate, notes: taskRepresentation.notes, isComplete: taskRepresentation.isComplete, context: context)
    }
}

struct TaskRepresentation: Codable, Equatable {
    var description: String
    let categoryId: UUID
    let assigneeIds: [UUID]
    var dueDate: Date
    var notes: [UUID]
    let identifier: UUID
    var isComplete: Bool
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.description == rhs.description &&
        lhs.assigneeIds == rhs.assigneeIds &&
        lhs.dueDate == rhs.dueDate &&
        lhs.isComplete == rhs.isComplete
    }
}
