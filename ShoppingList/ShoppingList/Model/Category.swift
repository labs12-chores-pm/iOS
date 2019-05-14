//
//  Struct.swift
//  ShoppingList
//
//  Created by Nikita Thomas on 2/19/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import CoreData

extension Category {
    
    convenience init(createdAt: Date = Date(), householdId: UUID, name: String, tasks: [UUID], context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        
        self.tasks = tasks
        self.createdAt = createdAt
        self.householdId = householdId
        self.name = name
    }
    
    @discardableResult convenience init?(categoryRepresentation: CategoryRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(createdAt: categoryRepresentation.createdAt, householdId: categoryRepresentation.householdId, name: categoryRepresentation.name, tasks: categoryRepresentation.tasks, context: context)
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
