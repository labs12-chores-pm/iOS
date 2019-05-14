//
//  Note.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/13/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import CoreData

extension Note {
    
    convenience init(text: String, memberId: UUID, date: Date = Date(), taskId: UUID, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.text = text
        self.memberId = memberId
        self.date = date
        self.taskId = taskId
    }
    
    convenience init(noteRepresentation: NoteRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(text: noteRepresentation.text, memberId: noteRepresentation.memberId, date: noteRepresentation.date, taskId: noteRepresentation.taskId, context: context)
    }
}

struct NoteRepresentation: Codable {
    let text: String
    let memberId: UUID
    let date: Date
    let taskId: UUID
}
