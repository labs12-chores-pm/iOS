//
//  CategoryController.swift
//  ShoppingList
//
//  Created by Jerrick Warren on 5/16/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

class CategoryController {
    
    // CRUD
    // Tasks vs Task ?? (Naming)
    func createCategory(tasks: [Task] = [], createdAt: Date, householdId: UUID, name: String) {
        let category = Category(tasks: tasks, createdAt: createdAt, householdId: householdId, name: name, identifier: UUID())
        put(category: category)
    }
    
    func updateCategory(category: Category, tasks: [Task] = [], householdId: UUID? = nil, name: String? = nil ) {
        
        var categoryCopy = category
        categoryCopy.tasks += tasks
        categoryCopy.name = name ?? categoryCopy.name
        put(category: categoryCopy)
    }
    
    // Test function
    func fetchCategoriesTest(completion: @escaping ([Category]?, Error?) -> Void) {
        
        let categoriesURL = baseURL.appendingPathComponent("category").appendingPathExtension("json")
        let request = URLRequest(url: categoriesURL)
        
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
                let categories = try JSONDecoder().decode([Category].self, from: data)
                completion(categories, nil)
            } catch {
                completion(nil, NetworkError.decodingData)
            }
            return
        }
        
        task.resume()
    }
    
    
    func fetchCategories(householdId: UUID, completion: @escaping ([Category]?, Error?) -> Void) {
        
        let categoriesURL = baseURL.appendingPathComponent("categories").appendingPathExtension("json")
        let request = URLRequest(url: categoriesURL)
        
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
                let categories = try JSONDecoder().decode([Category].self, from: data)
                let householdCategories = categories.filter({ $0.householdId == householdId })
                completion(householdCategories, nil)
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
            request.httpBody = try JSONEncoder().encode(category)
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
