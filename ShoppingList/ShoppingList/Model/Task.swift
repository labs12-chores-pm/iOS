//
//  Item.swift
//  ShoppingList
//
//  Created by Nikita Thomas on 2/19/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

enum Recurrence: Int, Codable {
    case once = 0
    case weekly = 1
    case monthly = 2
    case yearly = 3
}

struct Task: Codable, Equatable {
    var description: String
    let categoryId: UUID
    let householdId: UUID
    var assigneeIds: [UUID]
    var dueDate: Date
    var recurrence: Recurrence
    var notes: [Note]
    let identifier: UUID
    var isComplete: Bool
    var isPending: Bool
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.description == rhs.description &&
        lhs.assigneeIds == rhs.assigneeIds &&
        lhs.dueDate == rhs.dueDate &&
        lhs.isComplete == rhs.isComplete &&
        lhs.recurrence == rhs.recurrence &&
        lhs.isPending == rhs.isPending
    }
    
    enum CodingKeys: String, CodingKey {
        case description, categoryId, assigneeIds, dueDate, notes, identifier, isComplete, recurrence, isPending, householdId
    }
    
    init(description: String, categoryId: UUID, assigneeIds: [UUID]?, dueDate: Date, notes: [Note]?, recurrence: Recurrence = .once, householdId: UUID) {
        self.description = description
        self.categoryId = categoryId
        self.assigneeIds = assigneeIds ?? []
        self.dueDate = dueDate
        self.notes = notes ?? []
        self.identifier = UUID()
        self.isComplete = false
        self.recurrence = recurrence
        self.isPending = false
        self.householdId = householdId
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(description, forKey: .description)
        try container.encode(categoryId, forKey: .categoryId)
        var assigneesContainer = container.nestedUnkeyedContainer(forKey: .assigneeIds)
        for assignee in assigneeIds {
            try assigneesContainer.encode(assignee.uuidString)
        }
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(recurrence.rawValue, forKey: .recurrence)
        try container.encode(notes, forKey: .notes)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(isComplete, forKey: .isComplete)
        try container.encode(isPending, forKey: .isPending)
        try container.encode(householdId, forKey: .householdId)
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let description = try container.decode(String.self, forKey: .description)
        let categoryIdString = try container.decode(String.self, forKey: .categoryId)
        let categoryId = UUID(uuidString: categoryIdString)!
        
        let assigneeIdsContainer = try container.decodeIfPresent([String].self, forKey: .assigneeIds)
        
        var assigneeIds: [UUID] = []
        
        if let assigneeIdsContainer = assigneeIdsContainer {
            
            for assignee in assigneeIdsContainer {
                let id = UUID(uuidString: assignee)!
                assigneeIds.append(id)
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
        
        let householdIdString = try container.decode(String.self, forKey: .householdId)
        let householdId = UUID(uuidString: householdIdString)!
        
        let identifierString = try container.decode(String.self, forKey: .identifier)
        let identifier = UUID(uuidString: identifierString)!
        
        let isComplete = try container.decode(Bool.self, forKey: .isComplete)
        
        let recurrenceValue = try container.decodeIfPresent(Int.self, forKey: .recurrence)
        let recurrence = Recurrence.init(rawValue: recurrenceValue ?? 0)!
        
        let isPending = try container.decodeIfPresent(Bool.self, forKey: .isPending)
        
        self.description = description
        self.categoryId = categoryId
        self.assigneeIds = assigneeIds
        self.dueDate = dueDate
        self.notes = []
        self.identifier = identifier
        self.isComplete = isComplete
        self.recurrence = recurrence
        self.isPending = isPending ?? false
        self.householdId = householdId
    }
}
