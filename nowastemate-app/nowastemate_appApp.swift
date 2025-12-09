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
    //https://www.youtube.com/watch?v=gZ86gmXmuXE
    @StateObject var authVM = AuthViewModel()
    @StateObject var familyVM = FamilyViewModel()
    @StateObject var recipeVM = RecipeViewModel()
    @StateObject private var barcodeScanVM = CameraViewModel()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authVM)
                .environmentObject(familyVM)
                .environmentObject(recipeVM)
                .environmentObject(barcodeScanVM)
                .task {
                    await barcodeScanVM.requestDataScanerAccessStatus()
                }
        }
    }
}
