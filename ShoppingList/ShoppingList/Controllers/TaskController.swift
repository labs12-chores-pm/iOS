//
//  TaskController.swift
//  ShoppingList
//
//  Created by Jerrick Warren on 5/16/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

class TaskController {
    
    func createTask(description: String, categoryId: UUID, assineeIds: [UUID], dueDate: Date, notes: [Note] = [] , isComplete: Bool) {
        
        let task = Task(description: description, categoryId: categoryId, assigneeIds: assineeIds, dueDate: dueDate, notes: notes, identifier: UUID(), isComplete: isComplete)
        put(task: task)
    }
    
    
    func updateTask(task: Task , description: String?, categoryId: UUID? = nil, assignIds: [UUID]? = nil, dueDate: Date? = nil, notes: [Note]? = nil, isComplete: Bool = false) {
        
        var taskCopy = task
        
        taskCopy.description = description ?? taskCopy.description
        
        if let assigneeIds = assignIds {
            taskCopy.assigneeIds = task.assigneeIds + assigneeIds
        }
        
        taskCopy.dueDate = dueDate ?? taskCopy.dueDate
        taskCopy.notes = notes ?? taskCopy.notes
       
        put(task: taskCopy)
        
    }
    
    func fetchTasks(categoryId: UUID, completion: @escaping ([Task]?, Error?) -> Void) {
        
        let tasksURL = baseURL.appendingPathComponent("tasks").appendingPathExtension("json")
        let request = URLRequest(url: tasksURL)
        
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
                let tasks = try JSONDecoder().decode([Task].self, from: data)
                let tasksInCategory = tasks.filter({ $0.categoryId == categoryId })
                completion(tasksInCategory, nil)
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
