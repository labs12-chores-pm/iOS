//
//  Struct.swift
//  ShoppingList
//
//  Created by Nikita Thomas on 2/19/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import CoreData

extension Category {
    
    convenience init(tasks: [UUID], createdAt: Date, householdId: UUID, name: String, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.tasks = tasks
        self.createdAt = createdAt
        self.householdId = householdID
        self.name = name
    }
    
    convenience init(categoryRepresentation: CategoryRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.tasks = categoryRepresentation.tasks
        self.createdAt = categoryRepresentation.createdAt
        self.householdId = categoryRepresentation.householdId
        self.name = categoryRepresentation.name
    }
}

struct CategoryRepresentation: Codable, Equatable {
    var tasks: [UUID]
    let createdAt: Date
    let householdId: UUID
    var name: String
    
    static func == (lhs: CategoryRepresentation, rhs: CategoryRepresentation) -> Bool {
        return lhs.tasks == rhs.tasks &&
            lhs.name == rhs.name
    }
}
