//
//  Struct.swift
//  ShoppingList
//
//  Created by Nikita Thomas on 2/19/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

struct Category: Codable, Equatable {
    var tasks: [Task]?
    let createdAt: Date
    let householdId: UUID
    var name: String
    let identifier: UUID
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.tasks == rhs.tasks &&
            lhs.name == rhs.name &&
        lhs.identifier == rhs.identifier
    }
    
    enum CodingKeys: String, CodingKey {
        case tasks, createdAt, housholdId, name, identifier
    }
    
    init(tasks: [Task]?, householdId: UUID, name: String, identifier: UUID = UUID()) {
        self.tasks = tasks
        self.createdAt = Date()
        self.householdId = householdId
        self.name = name
        self.identifier = identifier
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let tasks = try container.decodeIfPresent([Task].self, forKey: .tasks)
        let date = try container.decode(Double.self, forKey: .createdAt)
        let createdAt = Date(timeIntervalSince1970: date)
        let householdString = try container.decode(String.self, forKey: .housholdId)
        let housholdId = UUID(uuidString: householdString)
        let name = try container.decode(String.self, forKey: .name)
        let identifierString = try container.decode(String.self, forKey: .identifier)
        let identifier = UUID(uuidString: identifierString)
        
        self.tasks = tasks
        self.createdAt = createdAt
        self.householdId = housholdId!
        self.name = name
        self.identifier = identifier!
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(tasks, forKey: .tasks)
        
        let time = createdAt.timeIntervalSince1970
        
        try container.encode(time, forKey: .createdAt)
        try container.encode(householdId.uuidString, forKey: .housholdId)
        try container.encode(name, forKey: .name)
        try container.encode(identifier.uuidString, forKey: .identifier)
    }
}
