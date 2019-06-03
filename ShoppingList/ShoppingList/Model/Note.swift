//
//  Note.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/13/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

struct Note: Codable {
    let text: String
    let memberId: UUID
    let date: Date
    let taskId: UUID
    let identifier: UUID
    let senderName: String
}
