//
//  HouseholdController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/13/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import CoreData

class HouseholdController {
    
    func createHousehold(name: String, creatorId: UUID, memberIds: [UUID] = []) -> Household {
        
        let members = memberIds + [creatorId]
        
        let newHousehold = Household(name: name, identifier: UUID(), creatorId: creatorId, memberIds: members, adminIds: [creatorId], categories: [])
        put(household: newHousehold)
        return newHousehold
    }
    
    @discardableResult func updateHousehold(household: Household, name: String? = nil, memberIds: [UUID], adminIds: [UUID], categories: [Category], invite: Invite? = nil) -> Household {
        
        var updatedHousehold = household
        
        updatedHousehold.name = name ?? household.name
        updatedHousehold.memberIds.append(contentsOf: memberIds)
        updatedHousehold.adminIds.append(contentsOf: adminIds)
        
        let dateFormatter = DateFormatter()
        
        
        if let invite = invite {
            updatedHousehold.inviteCode = invite.inviteCode
            
            let dateString = dateFormatter.string(from: invite.createdAt)
            updatedHousehold.inviteDate = dateString
        } else {
            updatedHousehold.inviteCode = household.inviteCode
            updatedHousehold.inviteDate = household.inviteDate
        }
        
        if updatedHousehold.categories != nil {
            updatedHousehold.categories?.append(contentsOf: categories)
        } else {
            updatedHousehold.categories = categories
        }
        
        put(household: updatedHousehold)
        return updatedHousehold
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
    
    func fetchHousehold(inviteCode: String, completion: @escaping (Household?, Error?) -> Void) {
        
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
                let householdsResponse = try JSONDecoder().decode([String: Household].self, from: data)
                let households = householdsResponse.compactMap({ $0.value })
                let household = households.filter({ $0.inviteCode == inviteCode }).first
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
                let householdsResponse = try JSONDecoder().decode([String: Household].self, from: data)
                var households: [Household] = []
                for household in householdsResponse {
                    households.append(household.value)
                }
                let userHouseholds = households.filter({ return $0.memberIds.contains(user.identifier) })
                let sortedHouseholds = userHouseholds.sorted(by: { (household1, household2) -> Bool in
                    household1.name < household2.name
                })
                completion(sortedHouseholds, nil)
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
    
    let baseURL = URL(string: "https://test-6f4fe.firebaseio.com/")!
}
