//
//  User.swift
//  
//
//  Created by Nikita Thomas on 2/19/19.
//

import Foundation

struct User: Codable {
    var email: String
    var identifier: UUID
    var name: String
    var subscriptionType: Int
    var profilePicture: String?
    var currentHouseholdId: UUID
}
