//
//  User.swift
//  
//
//  Created by Nikita Thomas on 2/19/19.
//

import CoreData

extension User {
    
    convenience init(email: String, identifier: UUID = UUID(), name: String, subscriptionType: Int = 0, profilePicture: String?, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.email = email
        self.identifier = identifier
        self.name = name
        self.subscriptionType = Int16(subscriptionType)
        
        if let profileString = profilePicture {
            self.profilePicture = URL(string: profileString)!
        } else {
            self.profilePicture = nil
        }
    }
    
    convenience init(userRepresentation: UserRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(email: userRepresentation.email, identifier: userRepresentation.identifier, name: userRepresentation.name, subscriptionType: userRepresentation.subscriptionType, profilePicture: userRepresentation.profilePicture, context: context)
    }
}

struct UserRepresentation: Codable {
    var email: String
    var identifier: UUID
    var name: String
    var subscriptionType: Int
    var profilePicture: String?
}
