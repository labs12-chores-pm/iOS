//
//  Item.swift
//  ShoppingList
//
//  Created by Nikita Thomas on 2/19/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

class Task: Codable {
    var desciption: String
    let categoryId: UUID
    let assigneeIds: [UUID]
    var dueDate: Date
    var notes: [Note]
    let identifier: UUID
    var isComplete: Bool
}
