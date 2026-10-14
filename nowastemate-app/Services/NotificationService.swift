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
    
}
