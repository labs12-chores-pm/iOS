//
//  TaskController.swift
//  ShoppingList
//
//  Created by Jerrick Warren on 5/16/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

class TaskController {
 
    var task: Task?
    
    // CRUD
    
    func createTask(description: String, categoryId: UUID, assineeIds: [UUID], dueDate: Date, notes: [Note] = [] , isComplete: Bool) {
        
        let task = Task(description: description, categoryId: categoryId, assigneeIds: assineeIds, dueDate: dueDate, notes: notes, identifier: UUID(), isComplete: isComplete)
        put(task: task)
        
    }
    
    
    func updateTask(task:Task , description: String?, categoryId: UUID? = nil, assignIds: [UUID]? = nil, dueDate: Date? = nil, notes: [Note]? = nil, isComplete: False) {
        
        var taskCopy = task
        
        taskCopy.description = description ?? taskCopy.description
        taskCopy.categoryId = categoryId ?? taskCopy.categoryId // ??
        taskCopy.assigneeIds = assignIds ?? taskCopy.assigneeIds
        taskCopy.dueDate = dueDate ?? taskCopy.dueDate
        taskCopy.notes = notes ?? taskCopy.notes
       
        put(task: taskCopy)
        
    }
    
    func fetchTask(taskId: UUID, completion: @escaping (Task?, Error?) -> Void) {
        
        let tasksURL = baseURL.appendingPathComponent("tasks")
        let requestURL = tasksURL.appendingPathComponent(taskId.uuidString).appendingPathExtension("json")
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
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(user, nil)
            } catch {
                completion(nil, NetworkError.decodingData)
            }
            return
        }
        
        task.resume()
    }
    
    
    private func put(task: Task, completion: @escaping (Error?) -> Void = {_ in }) {
        
        let id = task.identifier.uuidString
        let usersURL = baseURL.appendingPathComponent("tasks")
        let requestURL = usersURL.appendingPathComponent(id).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(task)
        } catch {
            print("Error encoding data: \(task)")
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







