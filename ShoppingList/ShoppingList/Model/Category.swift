//
//  Struct.swift
//  ShoppingList
//
//  Created by Nikita Thomas on 2/19/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

struct Category: Codable {
    var tasks: [Task]
    let createdAt: Date
    let householdId: UUID
    var name: String
}
