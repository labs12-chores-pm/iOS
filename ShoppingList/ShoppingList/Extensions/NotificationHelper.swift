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
    
    
    func scheduleDelivery(name: String, address: String, numberOfItems: Int) {
        
        let content = UNMutableNotificationContent()
        content.title = "\(name)'s order"
        content.body = "Your \(numberOfItems) items will be delivered to \(address) within the hour"
        
        
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
}
