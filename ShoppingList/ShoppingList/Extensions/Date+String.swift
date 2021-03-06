//
//  Date+String.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/28/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

extension Date {
    
    func string(style: DateFormatter.Style = .none, showTime: Bool = false) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = style
        dateFormatter.timeStyle = showTime ? style : .none
        
        return dateFormatter.string(from: self)
    }
    
    func string(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func removeTime() -> Date {
        let components = Calendar.current.dateComponents([.month, .day, .year], from: self)
        return Calendar.current.date(from: components)!
    }
}
