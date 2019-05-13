//
//  Household.swift
//  ShoppingList
//
//  Created by Nikita Thomas on 2/19/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

class Household: Codable {
    var name: String
    let identifier: UUID
    let creatorId: UUID
    var memberIds: [UUID]
    var adminIds: [UUID]
    var categories: [Category]
}

