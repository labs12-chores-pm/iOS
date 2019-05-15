//
//  Struct.swift
//  ShoppingList
//
//  Created by Nikita Thomas on 2/19/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

struct Category: Codable, Equatable {
    var tasks: [Task]
    let createdAt: Date
    let householdId: UUID
    var name: String
    let identifier: UUID
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.tasks == rhs.tasks &&
            lhs.name == rhs.name &&
        lhs.identifier == rhs.identifier
    }
}
