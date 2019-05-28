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
    @discardableResult func createCategory(householdId: UUID, name: String) -> Category {
        let category = Category(tasks: nil, householdId: householdId, name: name)
        put(category: category)
        
        return category
    }
    
    func updateCategory(category: Category, tasks: [Task]?, householdId: UUID? = nil, name: String? = nil ) {
        
        var categoryCopy = category
        
        if let tasks = tasks {
            categoryCopy.tasks!.append(contentsOf: tasks)
        }
        
        categoryCopy.name = name ?? categoryCopy.name
        put(category: categoryCopy)
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
                let categoriesResponse = try JSONDecoder().decode([String: Category].self, from: data)
                var categories: [Category] = []
                for category in categoriesResponse {
                    categories.append(category.value)
                }
                let householdCategories = categories.filter({ $0.householdId == householdId })
                completion(householdCategories, nil)
            } catch {
                completion(nil, NetworkError.decodingData)
            }
            return
        }
        
        task.resume()
    }
    
    func delete(category: Category, completion: @escaping (Error?) -> Void) {
        
        let id = category.identifier.uuidString
        let categoriesURL = baseURL.appendingPathComponent("categories")
        let requestURL = categoriesURL.appendingPathComponent(id).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
            print(response!)
            completion(error)
        }
        
        task.resume()
    }
    
    
    private func put(category: Category, completion: @escaping (Error?) -> Void = {_ in }) {
        
        let id = category.identifier.uuidString
        let usersURL = baseURL.appendingPathComponent("categories")
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
        
        print(category)
    }
    
    let baseURL = URL(string: "https://test-6f4fe.firebaseio.com/")!
}
