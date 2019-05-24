//
//  Household.swift
//  ShoppingList
//
//  Created by Nikita Thomas on 2/19/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

struct Household: Codable, Equatable {
    var name: String
    let identifier: UUID
    let creatorId: UUID
    var memberIds: [UUID]
    var adminIds: [UUID]
    var categories: [Category]?
    var inviteDate: String
    var inviteCode: String
    
    static func == (lhs: Household, rhs: Household) -> Bool {
        return lhs.name == rhs.name &&
        lhs.identifier == rhs.identifier &&
        lhs.creatorId == rhs.creatorId &&
        lhs.memberIds == rhs.memberIds &&
        lhs.adminIds == rhs.adminIds &&
        lhs.categories == rhs.categories
    }
    
    enum CodingKeys: String, CodingKey {
        case name, identifier, creatorId, memberIds, adminIds, categories, inviteDate, inviteCode
    }
    
    init(name: String, identifier: UUID, creatorId: UUID, memberIds: [UUID], adminIds: [UUID], categories: [Category]) {
        self.name = name
        self.identifier = identifier
        self.creatorId = creatorId
        self.memberIds = memberIds
        self.adminIds = adminIds
        self.categories = categories
        
        let invite = Invite()
        let dateFormatter = DateFormatter()
        
        self.inviteDate = dateFormatter.string(from: invite.createdAt)
        self.inviteCode = invite.inviteCode
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let name = try container.decode(String.self, forKey: .name)
        
        let identifierString = try container.decode(String.self, forKey: .identifier)
        let identifier = UUID(uuidString: identifierString)!
        
        let creatorString = try container.decode(String.self, forKey: .creatorId)
        let creatorId = UUID(uuidString: creatorString)!
        
        let membersString = try container.decode([String].self, forKey: .memberIds)
        
        let membersIds = membersString.compactMap { UUID(uuidString: $0)! }
        
        let adminStrings = try container.decode([String].self, forKey: .adminIds)
        
        let adminIds = adminStrings.compactMap { UUID(uuidString: $0)! }
        
        let categories = try container.decodeIfPresent([Category].self, forKey: .categories)
        
        let inviteDate = try container.decodeIfPresent(String.self, forKey: .inviteDate)
        let inviteCode = try container.decodeIfPresent(String.self, forKey: .inviteCode)
        
        self.name = name
        self.identifier = identifier
        self.creatorId = creatorId
        self.memberIds = membersIds
        self.adminIds = adminIds
        self.categories = categories
        
        let invite = Invite()
        
        let dateFormatter = DateFormatter()
        
        self.inviteDate = inviteDate ?? dateFormatter.string(from: invite.createdAt)
        self.inviteCode = inviteCode ?? invite.inviteCode
    }
}
