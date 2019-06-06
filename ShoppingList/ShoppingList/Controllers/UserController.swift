////
////  UserController.swift
////  ShoppingList
////
////  Created by Nikita Thomas on 2/20/19.
////  Copyright © 2019 Lambda School Labs. All rights reserved.
////

import Foundation

class UserController {
    
    func createUser(email: String, name: String, subscriptionType: Int = 0, profilePicture: String?, currentHouseholdId: UUID, identifier: UUID) -> User {
        let user = User(email: email, identifier: identifier, name: name, subscriptionType: subscriptionType, profilePicture: profilePicture, currentHouseholdId: currentHouseholdId)
        put(user: user)
        return user
    }
    
    func updateUser(user: User, email: String? = nil, name: String? = nil, subscriptionType: Int? = nil, profilePicture: String? = nil, currentHouseholdId: UUID? = nil, completion: @escaping (Error?) -> Void = {_ in }) {
        
        var userCopy = user
        userCopy.email = email ?? user.email
        userCopy.name = name ?? user.name
        userCopy.subscriptionType = subscriptionType ?? user.subscriptionType
        userCopy.profilePicture = profilePicture ?? user.profilePicture
        userCopy.currentHouseholdId = currentHouseholdId ?? user.currentHouseholdId
        put(user: userCopy)
        completion(nil)
    }
    
    func fetchUsers(inHousehold household: Household, completion: @escaping ([User]?, Error?) -> Void) {
        
        let usersURL = baseURL.appendingPathComponent("users").appendingPathExtension("json")
        let request = URLRequest(url: usersURL)
        
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
                let usersResponse = try JSONDecoder().decode([String: User].self, from: data)
                let userValues = usersResponse.compactMap({ $0.value })
                let usersInHousehold = userValues.filter({ household.memberIds.contains($0.identifier) })
                completion(usersInHousehold, nil)
            } catch {
                completion(nil, NetworkError.decodingData)
            }
            return
        }
        
        task.resume()
    }
    
    func fetchUser(userId: UUID, completion: @escaping (User?, Error?) -> Void) {
        
        let usersURL = baseURL.appendingPathComponent("users")
        let requestURL = usersURL.appendingPathComponent(userId.uuidString).appendingPathExtension("json")
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
                let user = try JSONDecoder().decode(User?.self, from: data)
                completion(user, nil)
            } catch {
                completion(nil, NetworkError.decodingData)
            }
            return
        }
        
        task.resume()
    }
    
    func fetchUserWithEmail(email: String, completion: @escaping (User?, Error?) -> Void) {
        
        let usersURL = baseURL.appendingPathComponent("users").appendingPathExtension("json")
        let request = URLRequest(url: usersURL)
        
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
                let usersResponse = try JSONDecoder().decode([String: User].self, from: data)
                let users = usersResponse.compactMap({ $0.value })
                let filteredUsers = users.filter({ $0.email == email })
                let user = filteredUsers.first
                completion(user, nil)
            } catch {
                completion(nil, NetworkError.decodingData)
            }
            return
        }
        
        task.resume()
    }
    
    private func put(user: User, completion: @escaping (Error?) -> Void = {_ in }) {
        
        let id = user.identifier.uuidString
        let usersURL = baseURL.appendingPathComponent("users")
        let requestURL = usersURL.appendingPathComponent(id).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(user)
        } catch {
            print("Error encoding data: \(user)")
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
