//
//  Note.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/13/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import CoreData

extension Note {
    
    convenience init(text: String, memberId: UUID, taskId: UUID, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.text = text
        self.memberId = memberId
        self.date = Date()
        self.taskId = taskId
    }
    
    convenience init(noteRepresentation: NoteRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.text = noteRepresentation.text
        self.memberId = noteRepresentation.memberId
        self.date = noteRepresentation.date
        self.taskId = noteRepresentation.taskId
    }
}

struct NoteRepresentation: Codable {
    let text: String
    let memberId: UUID
    let date: Date
    let taskId: UUID
}
