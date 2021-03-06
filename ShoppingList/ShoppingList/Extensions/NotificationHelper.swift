//
//  NotificationHelper.swift
//  ShoppingList
//
//  Created by Jerrick Warren on 5/28/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//


import Foundation
import UserNotifications

class NotificationHelper: NSObject, UNUserNotificationCenterDelegate {
    
    //Helper method to get the authorization status for notifications
    func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    //Helper method to request notification authorization
    func requestAuthorization(completion: @escaping (Bool) -> Void ) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            if let error = error { NSLog("Error requesting authorization status for local notifications: \(error)") }
            
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    
    func scheduleTask(task: String, date: Date) {
        
        let content = UNMutableNotificationContent()
        content.title = "\(task)"
        content.body = "Your task:  \(task) will be due at \(date.string(style: .short, showTime: true)) "
        
        guard let triggerDate = Calendar.current.date(byAdding: .hour, value: -1, to: date) else { return }
        
        let components = Calendar.current.dateComponents([.year, .month, .hour, .day, .minute], from: triggerDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        print("This is the Triger Time \(triggerDate)")
}
    
    
}
