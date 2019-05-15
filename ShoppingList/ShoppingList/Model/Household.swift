//
//  Household.swift
//  ShoppingList
//
//  Created by Nikita Thomas on 2/19/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import CoreData

extension Household {
    
    convenience init(name: String, identifier: UUID = UUID(), creatorId: UUID, memberIds: [UUID], adminIds: [UUID], categories: [UUID], context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.name = name
        self.identifier = identifier
        self.creatorId = creatorId
        self.memberIds = memberIds
        self.adminIds = adminIds
        self.categories = categories
    }
    
    @discardableResult convenience init?(householdRepresentation: HouseholdRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(name: householdRepresentation.name, identifier: householdRepresentation.identifier, creatorId: householdRepresentation.creatorId, memberIds: householdRepresentation.memberIds, adminIds: householdRepresentation.adminIds, categories: householdRepresentation.categories, context: context)
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
        lhs.identifier == rhs.identifier &&
        lhs.creatorId == rhs.creatorId &&
        lhs.memberIds == rhs.memberIds &&
        lhs.adminIds == rhs.adminIds &&
        lhs.categories == rhs.categories
    }
    
    init(name: String, identifier: UUID = UUID(), creatorId: UUID, memberIds: [UUID], adminIds: [UUID], categories: [UUID]) {
        self.name = name
        self.identifier = identifier
        self.creatorId = creatorId
        self.memberIds = memberIds
        self.adminIds = adminIds
        self.categories = categories
    }
    
    init(household: Household) {
        guard let name = household.name, let identifier = household.identifier, let creatorId = household.creatorId,
            let memberIds = household.memberIds, let adminIds = household.adminIds, let categories = household.categories else { return }
        
        self.name = name
        self.identifier = identifier
        self.creatorId = creatorId
        self.memberIds = memberIds
        self.adminIds = adminIds
        self.categories = categories
    }
}
