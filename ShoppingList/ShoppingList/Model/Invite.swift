//
//  Invite.swift
//  ShoppingList
//
//  Created by Yvette Zhukovsky on 3/5/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

extension String {
    static let oneCode = "oneCode"
    static let twoCode = "twoCode"
    static let threeCode = "threeCode"
    static let fourCode = "fourCode"
    static let fiveCode = "fiveCode"
    static let sixCode = "sixCode"
    static let oneCountCode = "oneCountCode"
    static let fourCountCode = "fourCountCode"
    
    static func generateCode() -> String {
        
        let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        
        let defaults = UserDefaults.standard
        
        var one = defaults.string(forKey: .oneCode) ?? "A"
        var two = defaults.integer(forKey: .twoCode)
        var three = defaults.integer(forKey: .threeCode)
        var four = defaults.string(forKey: .fourCode) ?? "A"
        var five = defaults.integer(forKey: .fiveCode)
        var six = defaults.integer(forKey: .sixCode)
        var oneCount = defaults.integer(forKey: .oneCountCode)
        var fourCount = defaults.integer(forKey: .fourCountCode)
        
        let string = one + "\(two)\(three)" + four + "\(five)\(six)"
        
        defer {
            defaults.set(one, forKey: .oneCode)
            defaults.set(two, forKey: .twoCode)
            defaults.set(three, forKey: .threeCode)
            defaults.set(four, forKey: .fourCode)
            defaults.set(five, forKey: .fiveCode)
            defaults.set(six, forKey: .sixCode)
            defaults.set(oneCount, forKey: .oneCountCode)
            defaults.set(fourCount, forKey: .fourCountCode)
        }
        
        while three < 9 {
            three += 1
            return string
        }
        
        while three == 9 {
            three = 0
            two += 1
            return string
        }
        
        while two == 9 {
            two = 0
            
            if oneCount < alphabet.count {
                oneCount += 1
            } else {
                oneCount = 0
            }
            
            one = alphabet[oneCount]
            return string
        }
        
        while six < 9 {
            six += 1
            return string
        }
        
        while six == 9 {
            six = 0
            five += 1
            return string
        }
        
        while five == 9 {
            five = 0
            
            if fourCount < alphabet.count {
                fourCount += 1
            } else {
                fourCount = 0
            }
            
            four = alphabet[fourCount]
            return string
        }
        
        return string
    }
}

struct Invite: Codable {
    let inviteCode: String
    let createdAt: Date
    
    init() {
        self.inviteCode = .generateCode()
        self.createdAt = Date()
    }
}
