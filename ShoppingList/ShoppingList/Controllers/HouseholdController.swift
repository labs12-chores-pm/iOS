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
    
    func updateHousehold(household: Household, name: String?, memberIds: [UUID], adminIds: [UUID], categories: [Category]) {
        
        household.name = name ?? household.name
        household.memberIds.append(contentsOf: memberIds)
        household.adminIds.append(contentsOf: adminIds)
        household.categories.append(contentsOf: categories)
        
        put(household: household)
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
        
        do {
            request.httpBody = try JSONEncoder().encode(household)
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
    
    let baseURL = URL(string: "https://my-json-server.typicode.com/ryanboris/mockiosserver")!
}
