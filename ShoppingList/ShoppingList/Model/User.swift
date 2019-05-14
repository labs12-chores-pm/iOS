//
//  User.swift
//  
//
//  Created by Nikita Thomas on 2/19/19.
//

import CoreData

extension User {
    
    convenience init(email: String, name: String, subscriptionType: Int = 0, profilePicture: String?, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.email = email
        self.identifier = UUID()
        self.name = name
        self.subscriptionType = subscriptionType
        self.profilePicture = profilePicture
    }
    
    convenience init(userRepresentation: UserRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.email = userRepresentation.email
        self.identifier = userRepresentation.identifier
        self.name = userRepresentation.name
        self.subscriptionType = userRepresentation.subscriptionType
        self.profilePicture = userRepresentation.profilePicture
    }
}

struct UserRepresentation: Codable {
    var email: String
    var identifier: UUID
    var name: String
    var subscriptionType: Int
    var profilePicture: String?
}
