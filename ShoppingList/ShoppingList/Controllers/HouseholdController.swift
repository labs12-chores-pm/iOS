//
//  HouseholdController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/13/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import CoreData

class HouseholdController {
    
    func createHousehold(name: String, creatorId: UUID, memberIds: [UUID] = []) {
        
        let newHousehold = Household(name: name, identifier: UUID(), creatorId: creatorId, memberIds: [], adminIds: [creatorId], categories: [])
        saveToCoreData()
        put(household: newHousehold)
    }
    
    func updateHousehold(household: Household, name: String?, memberIds: [UUID], adminIds: [UUID], categories: [UUID]) {
        
        var newHousehold = HouseholdRepresentation(household: household)
        newHousehold.name = name ?? newHousehold.name
        newHousehold.memberIds.append(contentsOf: memberIds)
        newHousehold.adminIds.append(contentsOf: adminIds)
        newHousehold.categories.append(contentsOf: categories)
        
        if let updatedHousehold = Household(householdRepresentation: newHousehold) {
            saveToCoreData()
            put(household: updatedHousehold)
        }
    }
    
    func deleteHousehold(household: Household, completion: @escaping (Error?) -> Void = {_ in }) {
        
        guard let id = household.identifier?.uuidString else { return }
        let householdsURL = baseURL.appendingPathComponent("households")
        let requestURL = householdsURL.appendingPathComponent(id).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
            print(response!)
            completion(error)
        }
        
        task.resume()
        
        deleteHousehold(household: household)
    }
    
    private func put(household: Household, completion: @escaping (Error?) -> Void = {_ in }) {
        
        guard let id = household.identifier?.uuidString else { return }
        let householdsURL = baseURL.appendingPathComponent("households")
        let requestURL = householdsURL.appendingPathComponent(id).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        let householdRep = HouseholdRepresentation(household: household)
        
        do {
            request.httpBody = try JSONEncoder().encode(householdRep)
        } catch {
            print("Error encoding data: \(household)")
            completion(NetworkError.encodingData)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (_, _, error) in
            
            if let error = error {
                print(error)
                completion(NetworkError.urlSession)
                return
            }
            completion(nil)
        }
        task.resume()
    }
    
    func deleteFromCoreData(household: Household, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.delete(household)
        saveToCoreData()
    }
    
    func saveToCoreData(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.perform {
            do {
                try context.save()
            } catch {
                context.reset()
            }
        }
    }
    
    let baseURL = URL(string: "https://my-json-server.typicode.com/ryanboris/mockiosserver")!
}
