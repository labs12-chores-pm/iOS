//
//  DatePicker.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 6/1/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

class DatePicker {
    
    init(setDate: Date? = nil) {
        self.setDate = setDate
        getDates()
        setIsPM()
    }
    
    let currentDate = Date()
    var calendar = Calendar.current
    var setDate: Date?
    var isPM: Bool?
    var dates: [Date]?
    
    func getDates() {
        
        var oldestDate: Date = currentDate
        
        if let setDate = setDate {
            oldestDate = setDate.timeIntervalSince1970 > currentDate.timeIntervalSince1970 ? currentDate : setDate
        }
        
        let hour = Calendar.current.component(.hour, from: oldestDate)
        
        if hour > 12 {
            isPM = true
        } else {
            isPM = false
        }

        let yearFromOldestDate = calendar.date(byAdding: .year, value: 1, to: oldestDate)!
        let numberOfDays = calendar.dateComponents([.day], from: oldestDate, to: yearFromOldestDate).day!

        var dates = [oldestDate]
        
        for i in 1...numberOfDays {
            let newDate = self.calendar.date(byAdding: .day, value: i, to: oldestDate)!
            dates.append(newDate)
        }

        self.dates = dates
    }
    
    func getDateStrings() -> [String] {
        
        guard let dates = dates else { return [] }
        
        var dateStrings: [String] = []
        
        for date in dates {
            
            if calendar.isDateInToday(date) {
                dateStrings.append("Today")
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "E MMM d"
                let dateString = dateFormatter.string(from: date)
                dateStrings.append(dateString)
            }
        }
        
        return dateStrings
    }
    
    func getHourStrings() -> [String] {
        
        let hoursCount = 240
        
        let date = setDate ?? currentDate
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h"
        
        let dateHourString = dateFormatter.string(from: date)
        
        var hour = Int(dateHourString)!
        
        var hours: [String] = [dateHourString]
        
        for _ in 0...hoursCount {
            
            if hour >= 12 {
                hour = 1
            } else {
                hour += 1
            }
            
            hours.append(String(hour))
        }

        return hours
    }
    
    func getMinutesStrings() -> [String] {
        
        let minutesCount = 240

        let date = setDate ?? currentDate
        var minute = calendar.dateComponents([.minute], from: date).minute!
        
        let minuteString = minute > 9 ? "\(minute)" : "0\(minute)"
        
        var minutes: [String] = [minuteString]
            
        for _ in 0...minutesCount {
            
            if minute == 59 {
                minute = 0
            } else {
                minute += 1
            }
            
            if minute < 10 {
                minutes.append("0\(minute)")
            } else {
                minutes.append(String(minute))
            }
        }
        
        return minutes
    }
    
    func getAMPM() -> [String] {
        return ["AM", "PM"]
    }
    
    func setIsPM() {
        guard let setDate = setDate else { return }
        
        var components = calendar.dateComponents([.month, .day, .year, .hour, .minute, .second], from: setDate)

        if let hour = components.hour, hour >= 12 {
            isPM = true
        } else {
            isPM = false
        }
    }
    
    func newIsPM(isPM: Bool) {
        guard let setDate = setDate else { return }
        
        var components = calendar.dateComponents([.month, .day, .year, .hour, .minute, .second], from: setDate)
        
        if isPM && components.hour! <= 12 {
            components.hour! += 12
        } else if components.hour! >= 12 {
            components.hour! -= 12
        }
        
        let date = calendar.date(from: components)
        
        self.setDate = date
    }
    
    func getAMPMIndex() -> Int {
        let date = setDate ?? currentDate
        let hour = calendar.component(.hour, from: date)
        return hour > 12 ? 1 : 0
    }
    
    func convertTo24HourTime(hour: Int) -> Int {
        
        var transformedHour = hour
        
        let isPM = self.isPM ?? false
        
        if isPM {
            transformedHour += 12
        }
        
        return transformedHour
    }
}
