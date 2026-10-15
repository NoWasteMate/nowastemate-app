//
//  NotificationService.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 14/10/2026.
//

import Foundation
import UserNotifications

//sources: https://www.youtube.com/watch?v=XnnDHDlPwLw
// https://dev.to/sam_programiz/swiftui-user-notifications-341a

struct NotificationService {
    static let shared = NotificationService()

    //this prompts to ask for permission
    func requestAuth(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]){ success, error in
            if success {
                print("Notifications accepted")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func schedule(product: Product){
        let content = UNMutableNotificationContent()
        content.title = "Product Expiring"
        content.subtitle = "\(product.name) will expire soon, head to the app to get it used!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: product.id!, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancel(product: Product){
        //https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/removependingnotificationrequests%28withidentifiers:%29
        //cancelling notifications for specific products. This will be applicable both when marking as consumed or wasted.
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [product.id!])
    }
    
}
