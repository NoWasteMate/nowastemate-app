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
    //https://stackoverflow.com/questions/64576286/how-do-i-schedule-a-notification-at-a-specific-time-and-then-repeat-it-every-x
    //https://www.hackingwithswift.com/forums/100-days-of-swiftui/getting-the-difference-between-two-dates-in-swiftui/3070
    //https://developer.apple.com/documentation/foundation/calendar/datecomponents(in:from:)
    //TODO: Allow the user to change the how they want to receive notifications
    //TODO: With the current setup below, they will be able to set the exact time and amount of days before, that they want reminders, once we changed the hardcoded values to user configurable settings
    func schedule(product: Product){
        
        let daysBefore = -1
        
        guard let triggerDate = Calendar.current.date(byAdding: .day, value: daysBefore, to: product.expiryDate!) else { return }
        
        //datecomponents uses the time zone of the device, so in this scenario it effectively becomes 1 day before expiry, at 9am in their calendar timezone
        var component = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
        component.hour = 9
        component.minute = 0
                
        //terminate in a scenario where they are backlogging already expired groceries
        //https://www.createwithswift.com/creating-valid-dates-using-the-swift-language/
        if Calendar.current.date(from: component)! < Date.now {
            return
        }
        
        //checking notification fires as expected with expected dates
        print("--------------------------")
        print("Date product will expiry: \(product.expiryDate)")
        print("Date we fire the notification: \(Calendar.current.date(from: component))")
        //https://www.codecademy.com/resources/docs/swiftui/notifications
        let content = UNMutableNotificationContent()
        content.title = "Product Expiring"
        content.body = "\(product.name) will expire soon, head to the app to get it used!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: false)
        
        let request = UNNotificationRequest(identifier: product.id!, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        print("notification added")
        print("--------------------------")

    }
    
    func cancel(product: Product){
        //https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/removependingnotificationrequests%28withidentifiers:%29
        //cancelling notifications for specific products. This will be applicable both when marking as consumed or wasted.
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [product.id!])
    }
    
}
