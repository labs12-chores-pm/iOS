//
//  NotesController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/15/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

class NotesController {
    
    func createNote(text: String, memberId: UUID, taskId: UUID) {
        let newNote = Note(text: text, memberId: memberId, date: Date(), taskId: taskId, identifier: UUID())
        put(note: newNote)
    }
    
    private func put(note: Note, completion: @escaping (Error?) -> Void = {_ in }) {
        
        let id = note.identifier.uuidString
        let notesURL = baseURL.appendingPathComponent("notes")
        let requestURL = notesURL.appendingPathComponent(id).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(note)
        } catch {
            print("Error encoding data: \(note)")
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
