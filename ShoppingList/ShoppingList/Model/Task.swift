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
    
    enum CodingKeys: String, CodingKey {
        case description, categoryId, assigneeIds, dueDate, notes, identifier, isComplete
    }
    
    init(description: String, categoryId: UUID, assigneeIds: [UUID]?, dueDate: Date, notes: [Note]?) {
        self.description = description
        self.categoryId = categoryId
        self.assigneeIds = assigneeIds ?? []
        self.dueDate = dueDate
        self.notes = notes ?? []
        self.identifier = UUID()
        self.isComplete = false
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let description = try container.decode(String.self, forKey: .description)
        let categoryIdString = try container.decode(String.self, forKey: .categoryId)
        let categoryId = UUID(uuidString: categoryIdString)!
        
        let assigneeIdsStrings = try container.decodeIfPresent([String].self, forKey: .assigneeIds)
        
        if let assigneeIdsStrings = assigneeIdsStrings {
            var assignees: [UUID] = []
            for assignee in assigneeIdsStrings {
                if let uuid = UUID(uuidString: assignee) {
                    assignees += [uuid]
                }
            }
        }
        
        let dueDateDouble = try container.decode(Double.self, forKey: .dueDate)
        let dueDate = Date(timeIntervalSince1970: dueDateDouble)
        
        let notesGroup = try container.decodeIfPresent([String: Note].self, forKey: .notes)
        
        if let notesGroup = notesGroup {
            var notes: [Note] = []
            for note in notesGroup {
                notes += [note.value]
            }
        }
        
        let identifierString = try container.decode(String.self, forKey: .identifier)
        let identifier = UUID(uuidString: identifierString)
        
        let isComplete = try container.decode(Bool.self, forKey: .isComplete)
        
        self.description = description
        self.categoryId = categoryId
        self.assigneeIds = []
        self.dueDate = dueDate
        self.notes = []
        self.identifier = UUID()
        self.isComplete = false
    }
}
