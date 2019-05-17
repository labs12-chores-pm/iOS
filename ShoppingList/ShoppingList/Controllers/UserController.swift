////
////  UserController.swift
////  ShoppingList
////
////  Created by Nikita Thomas on 2/20/19.
////  Copyright © 2019 Lambda School Labs. All rights reserved.
////
//
//import Foundation
//import Alamofire
//import SwiftKeychainWrapper
//import SimpleKeychain
//import Auth0
//import FirebaseStorage
//
//class UserController {
//
//    static let shared = UserController()
//    private var baseURL = URL(string: "https://shoppinglistredeploy.herokuapp.com")!
//
//    private func userToJSON(user: User) -> [String: Any]? {
//
//        guard let jsonData = try? JSONEncoder().encode(user) else {
//            return nil
//        }
//
//        do {
//            let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
//            return jsonDict
//        } catch {
//            return nil
//        }
//    }
//
//    func newUser(withName name: String, email: String, profilePicture: String, completion: @escaping (User?) -> Void) {
//
//        var newUser = User(email: email, name: name, profilePicture: profilePicture)
//        let url = baseURL.appendingPathComponent("user")
//
//        guard let userJSON = userToJSON(user: newUser) else { return }
//
//        Alamofire.request(url, method: .post, parameters: userJSON, encoding: JSONEncoding.default).validate().responseJSON { (response) in
//
//            switch response.result {
//            case .success(let value):
//
//                // TODO: API needs to be updated to return the userID in the Content
//                guard let jsonDict = value as? [String: Any], let userID = jsonDict["userID"] as? Int else {
//                    print("Could not get userID from API response")
//                    completion(nil)
//                    return
//                }
//
//                newUser.userID = userID
//                completion(newUser)
//
//            case .failure(let error):
//                print(error.localizedDescription)
//                completion(nil)
//                return
//            }
//        }
//    }
//
//
//    func updateProfilePic(withImage image: UIImage, completion: @escaping (Bool) -> Void) {
//
//        // save to Firebase Storage
//        // storage returns the url
//        // save url to user object
//        // update user profileImage url on API
//
//        let ref = Storage.storage().reference().child("profileImages").child(String(userID))
//
//        guard let compressedImage = image.resizeToDatabaseSize() else { completion(false); return}
//
//        if let uploadData = compressedImage.pngData() {
//
//            // Reduce size of image before upload
//            ref.putData(uploadData, metadata: nil) { (metaData, error) in
//                if let error = error {
//                    print("Error uploading profile image to storage: \(error)")
//                    completion(false)
//                }
//
//                ref.downloadURL(completion: { (url, error) in
//                    guard let url = url else { completion(false); return }
//
//                    self.updateUserImageOnAPI(withImageURL: url, completion: { (success) in
//                        completion(success)
//                    })
//                })
//            }
//        } else {
//            completion(false)
//        }
//    }
//
//
//    func updateUserImageOnAPI(withImageURL imageUrl: URL, completion: @escaping (Bool) -> Void) {
//
//        guard let accessToken = SessionManager.tokens?.idToken else {completion(false); return}
//        let headers: HTTPHeaders = [ "Authorization": "Bearer \(accessToken)"]
//
//        let url = baseURL.appendingPathComponent("user").appendingPathComponent(String(userID))
//
//        let imageURLString = imageUrl.absoluteString
//        userObject?.profilePicture = imageURLString
//
//        let json: [String: Any] = ["profilePicture": imageURLString]
//
//        Alamofire.request(url, method: .put, parameters: json, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
//
//            switch response.result {
//            case .success(_):
//
//                completion(true)
//                return
//            case .failure(let error):
//                print(error.localizedDescription)
//                completion(false)
//                return
//            }
//        }
//
//    }
//
//    func changeUserNameTo(name: String, completion: @escaping (Bool) -> Void) {
//
//        guard let accessToken = SessionManager.tokens?.idToken else {completion(false); return}
//        let headers: HTTPHeaders = [ "Authorization": "Bearer \(accessToken)"]
//
//        let url = baseURL.appendingPathComponent("user").appendingPathComponent(String(userID))
//
//        let json: [String: Any] = ["name": name]
//        userObject?.name = name
//
//        Alamofire.request(url, method: .put, parameters: json, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
//
//            switch response.result {
//            case .success(_):
//                completion(true)
//                return
//            case .failure(let error):
//                print(error.localizedDescription)
//                completion(false)
//                return
//            }
//
//        }
//
//    }
//
//
//    func updateUser(user: User, email: String? = nil, profilePicture: String? = nil, name: String? = nil, completion: @escaping (Bool, User?) -> Void) {
//
//        var myUser = user
//
//        if let email = email {
//            myUser.email = email
//        }
//
//
//        if let profilePicture = profilePicture {
//            myUser.profilePicture = profilePicture
//        }
//
//        if let name = name {
//            myUser.name = name
//        }
//
//        myUser.updatedAt = Date().dateToString()
//
//        guard let accessToken = SessionManager.tokens?.idToken else {completion(false, nil); return}
//        let headers: HTTPHeaders = [ "Authorization": "Bearer \(accessToken)"]
//
//        let url = baseURL.appendingPathComponent("user").appendingPathComponent(String(userID))
//
//        guard let userJSON = userToJSON(user: myUser) else { completion(false, nil); return }
//
//        Alamofire.request(url, method: .put, parameters: userJSON, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
//
//            switch response.result {
//            case .success(_):
//
//                completion(true, myUser)
//                return
//            case .failure(let error):
//                print(error.localizedDescription)
//                completion(false, nil)
//                return
//            }
//        }
//    }
//
//
//
//    func getUser(forID id: Int, completion: @escaping (Bool) -> Void) {
//        guard let accessToken = SessionManager.tokens?.idToken else {return}
//        let url = baseURL.appendingPathComponent("user").appendingPathComponent(String(id))
//         var request = URLRequest(url: url)
//
//        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//
//        Alamofire.request(request).validate().responseData { (response) in
//
//            switch response.result {
//            case .success(let value):
//
//                do {
//                    let decoder = JSONDecoder()
//                    let user = try decoder.decode(User.self, from: value)
//                    userObject = user
//                    completion(true)
//
//                } catch {
//                    print("Could not turn json into user")
//                    completion(false)
//                    return
//                }
//
//            case .failure(let error):
//                NSLog("getUser: \(error.localizedDescription)")
//                completion(false)
//                return
//            }
//        }
//
//    }
//
//
//    // MARK: Temporary Functions
//    // TODO: Remove this once we have way to get the real token
//    func getToken() -> String {
//        return "lalala"
//    }
//
//    func getUserID() -> Int32 {
//        return Int32(123)
//    }
//
//}

class UserController {
    
    func createUser(email: String, name: String, subscriptionType: Int = 0, profilePicture: String?, currentHouseholdId: UUID, identifier: UUID) -> User {
        let user = User(email: email, identifier: identifier, name: name, subscriptionType: subscriptionType, profilePicture: profilePicture, currentHouseholdId: currentHouseholdId)
        put(user: user)
        return user
    }
    
    func updateUser(user: User, email: String? = nil, name: String? = nil, subscriptionType: Int? = nil, profilePicture: String? = nil, currentHouseholdId: UUID? = nil) {
        
        var userCopy = user
        userCopy.email = email ?? user.email
        userCopy.name = name ?? user.name
        userCopy.subscriptionType = subscriptionType ?? user.subscriptionType
        userCopy.profilePicture = profilePicture ?? user.profilePicture
        userCopy.currentHouseholdId = currentHouseholdId ?? user.currentHouseholdId
        put(user: userCopy)
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
                let user = try JSONDecoder().decode(User.self, from: data)
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
