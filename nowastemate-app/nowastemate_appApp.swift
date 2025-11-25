//
//  nowastemate_appApp.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 7/10/25.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct nowastemate_appApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    //https://www.youtube.com/watch?v=gZ86gmXmuXE
    @StateObject var vm = UserViewModel()

    var body: some Scene {
        WindowGroup {
            LogInView()
                .environmentObject(vm)
        }
    }
}
