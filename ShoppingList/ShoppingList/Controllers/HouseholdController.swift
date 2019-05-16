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
        put(household: newHousehold)
    }
    
    func updateHousehold(household: Household, name: String? = nil, memberIds: [UUID], adminIds: [UUID], categories: [Category]) {
        
        var updatedHousehold = household
        
        updatedHousehold.name = name ?? household.name
        updatedHousehold.memberIds.append(contentsOf: memberIds)
        updatedHousehold.adminIds.append(contentsOf: adminIds)
        updatedHousehold.categories.append(contentsOf: categories)
        
        put(household: updatedHousehold)
    }
    
    func deleteHousehold(household: Household, completion: @escaping (Error?) -> Void) {
        
        let id = household.identifier.uuidString
        let householdsURL = baseURL.appendingPathComponent("households")
        let requestURL = householdsURL.appendingPathComponent(id).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
            print(response!)
            completion(error)
        }
        
        task.resume()
    }
    
    func fetchHousehold(householdId: UUID, completion: @escaping (Household?, Error?) -> Void) {
        
        let householdsURL = baseURL.appendingPathComponent("households")
        let requestURL = householdsURL.appendingPathComponent(householdId.uuidString).appendingPathExtension("json")
        let request = URLRequest(url: requestURL)
        
        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error {
                print(error)
                completion(nil, NetworkError.urlSession)
                return
            }
            
            guard let data = data else {
                print("No data")
                completion(nil, NetworkError.dataMissing)
                return
            }
            
            do {
                let household = try JSONDecoder().decode(Household.self, from: data)
                completion(household, nil)
            } catch {
                completion(nil, NetworkError.decodingData)
            }
            return
        }
        
        task.resume()
    }
    
    func fetchHouseholds(user: User, completion: @escaping ([Household]?, Error?) -> Void) {
        let householdsURL = baseURL.appendingPathComponent("households").appendingPathExtension("json")
        let request = URLRequest(url: householdsURL)
        
        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print(error)
                completion(nil, NetworkError.urlSession)
                return
            }
            
            guard let data = data else {
                print("No data")
                completion(nil, NetworkError.dataMissing)
                return
            }
            
            do {
                let households = try JSONDecoder().decode([Household].self, from: data)
                let userHouseholds = households.filter({ return $0.memberIds.contains(user.identifier) })
                completion(userHouseholds, nil)
            } catch {
                completion(nil, NetworkError.decodingData)
            }
            return
        }
        
        task.resume()
    }
    
    private func put(household: Household, completion: @escaping (Error?) -> Void = {_ in }) {
        
        let id = household.identifier.uuidString
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
