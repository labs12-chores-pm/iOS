//
//  CategoryController.swift
//  ShoppingList
//
//  Created by Jerrick Warren on 5/16/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

class CategoryController {
    
    var currentCategory: Category?
    
    // CRUD
    
    // Tasks vs Task ?? (Naming)
    func createCategory(tasks: [Task] = [], createdAt: Date, household: UUID, name: String) {
        let category = Category(tasks: tasks, createdAt: createdAt, householdId: householdId, name: name, identifier: UUID())
        
        put(category: category)
        
    }
    
    func updateCategory(category: Category, task: Task, createdAt: Date? = nil, householdId: UUID? = nil, name: String? = nil ) {
        
        // do we need a househouldId? that shouldn't be updated should it?
        var categoryCopy = category
        
        categoryCopy.tasks = task ?? categoryCopy.tasks
        categoryCopy.createdAt = createdAt ?? categoryCopy.createdAt
        categoryCopy.name = name ?? categoryCopy.name
        
        put(category: categoryCopy)
        
    }
    
    
    func fetchCategory(categoryId: UUID, completion: @escaping (Category?, Error?) -> Void) {
        
        let categoryURL = baseURL.appendingPathComponent("Category")
        let requestURL = categoryURL.appendingPathComponent(categoryId.uuidString).appendingPathExtension("json")
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
                let user = try JSONDecoder().decode(Category.self, from: data)
                completion(user, nil)
            } catch {
                completion(nil, NetworkError.decodingData)
            }
            return
        }
        
        task.resume()
    }
    
    
    private func put(category: Category, completion: @escaping (Error?) -> Void = {_ in }) {
        
        let id = category.identifier.uuidString
        let usersURL = baseURL.appendingPathComponent("category")
        let requestURL = usersURL.appendingPathComponent(id).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(task)
        } catch {
            print("Error encoding data: \(category)")
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
