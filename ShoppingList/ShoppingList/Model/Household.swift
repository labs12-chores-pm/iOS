//
//  Household.swift
//  ShoppingList
//
//  Created by Nikita Thomas on 2/19/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import CoreData

extension Household {
    
    convenience init(name: String, creatorId: UUID, memberIds: [UUID], adminIds: [UUID], categories: [UUID], context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.name = name
        self.identifier = UUID()
        self.creatorId = creatorId
        self.memberIds = memberIds
        self.adminIds = adminIds
        self.categories = categories
    }
    
    convenience init(householdRepresentation: HouseholdRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.name = householdRepresentation.name
        self.identifier = householdRepresentation.identifier
        self.creatorId = householdRepresentation.creatorId
        self.memberIds = householdRepresentation.memberIds
        self.adminIds = householdRepresentation.adminIds
        self.categories = householdRepresentation.categories
    }
}

struct HouseholdRepresentation: Codable, Equatable {
    var name: String
    let identifier: UUID
    let creatorId: UUID
    var memberIds: [UUID]
    var adminIds: [UUID]
    var categories: [UUID]
    
    static func == (lhs: HouseholdRepresentation, rhs: HouseholdRepresentation) -> Bool {
        return lhs.name == rhs.name &&
        lhs.memberIds == rhs.memberIds &&
        lhs.adminIds == rhs.adminIds &&
        lhs.categories == rhs.categories
    }
}
