//
//  NotesController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/15/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

class NotesController {
    
    func createNote(text: String, memberId: UUID, taskId: UUID) -> Note {
        let newNote = Note(text: text, memberId: memberId, date: Date(), taskId: taskId, identifier: UUID())
        put(note: newNote)
        return newNote
    }
    
    func fetchNotes(taskId: UUID, completion: @escaping ([Note]?, Error?) -> Void) {
        
        let notesURL = baseURL.appendingPathComponent("notes").appendingPathExtension("json")
        
        let task = URLSession.shared.dataTask(with: notesURL) { (data, _, error) in
            if let error = error {
                print(error)
                completion(nil, NetworkError.urlSession)
                return
            }
            
            guard let data = data else {
                print(NetworkError.dataMissing)
                completion(nil, NetworkError.dataMissing)
                return
            }
            
            do {
                let notesResponse = try JSONDecoder().decode([String: Note].self, from: data)
                let allNotes = notesResponse.map({ $0.value })
                let taskNotes = allNotes.filter({ $0.taskId == taskId })
                completion(taskNotes, nil)
            } catch {
                completion(nil, NetworkError.decodingData)
            }
            return
        }
        
        task.resume()
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
    
    let baseURL = URL(string: "https://test-6f4fe.firebaseio.com/")!
}
