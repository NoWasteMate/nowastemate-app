//
//  AuthViewModel.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 25/11/25.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Combine
import UserNotifications



//https://medium.com/@authfy/getting-started-with-swiftui-and-firebase-a-complete-guide-e7c25b7cd9c4


class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var isSignedIn: Bool = false
    @Published var loginError: Bool = false
    @Published var errorMessage: String?
    @Published var userInfo: UserInfo? = nil
    @Published var newDietaryRestrictions: [DietaryRestrictions] = []
    
    var productVM: ProductViewModel?

    
    private let authService = AuthService.shared
    
    init() {
        self.user = authService.currentUser
        self.isSignedIn = user != nil
    }
    
    func signIn(email: String, password: String) {
        authService.signIn(email: email, password: password) { error in
            if let error = error {
                print("Sign In Error:", error.localizedDescription)
                //https://www.avanderlee.com/swiftui/swiftui-alert-presenting/
                //https://stackoverflow.com/questions/77907410/how-to-show-swiftui-alerts-based-on-conditions
                //TODO: Better custom messaging as current method is fairly generic. Issue currently is that the errors from are not user friendly to read
                self.loginError = true
                
                return
            }
            self.user = self.authService.currentUser
            self.isSignedIn = true
        }
    }
        
    func signUp(email: String, password: String, firstName: String, lastName: String, dietaryRestrictions: [DietaryRestrictions], completion: @escaping (Error?) -> Void = { _ in }) {
        authService.signUp(email: email, password: password) { error in
            if let error = error {
                print("Sign Up Error:", error.localizedDescription)
                completion(error)
                return
            }
            self.user = self.authService.currentUser
            self.isSignedIn = true
            
            self.createUser(email: email, firstName: firstName, lastName: lastName, dietaryRestrictions: dietaryRestrictions)
            completion(nil)
        }
    }
        
    func signOut() {
        DispatchQueue.main.async {
            self.authService.signOut(){ error in
                if let error = error {
                    print("Error Signing out:", error.localizedDescription)
                    return
                }
                //ensure previous data is not still in system
                self.userInfo = nil
                self.user = self.authService.currentUser
                self.isSignedIn = false
                self.newDietaryRestrictions = []
            }
        }
    }
        
    func logToken() async {
        await AuthService.shared.logAuthID()
        
    }
    
    func createUser(email: String, firstName: String, lastName: String, dietaryRestrictions: [DietaryRestrictions]) {
        
        
        authService.syncUser(email: email, firstName: firstName, lastName: lastName, dietaryRestrictions: dietaryRestrictions) { result in
                switch result {
                case .success(let success):
                    self.errorMessage = nil
                    self.findUser()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        
    }
    
    func editRequest(email: String, firstName: String, lastName: String, dietaryRestrictions: [DietaryRestrictions], notificationDays: Int, notificationHour: Int, completion: @escaping (Error?) -> Void = { _ in }){
            self.authService.editUser(email: email, firstName: firstName, lastName: lastName, dietaryRestrictions: dietaryRestrictions, notificationDays: notificationDays, notificationHour: notificationHour) { error in
                DispatchQueue.main.async {
                if let error = error {
                    print("Error:", error.localizedDescription)
                    completion(error)
                    return
                }
                    
                //we need this so that once preferences are updated we update the notifications
                //this is to avoid an edge-case where user logs out, and does not log back in for a while, it would still use old notification preferences
                let center = UNUserNotificationCenter.current()
                    //wipe the existing list of scheduled notification
                center.removeAllPendingNotificationRequests()
                                    
                for product in self.productVM?.products ?? [] {
                        NotificationService.shared.schedule(product: product, notificationDays: notificationDays, notificationHour: notificationDays)
                }
                    
                    
                self.signOut()
                completion(nil)
            }
        }
    }
    
    func findUser()  {
            self.authService.getUserInfo(){ result in
                switch result {
                    //user is gotten and passed
                case .success(let user):
                    DispatchQueue.main.async {
                        self.userInfo = user
                        self.newDietaryRestrictions = self.userInfo?.dietaryRestrictions ?? []
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                        print(self.errorMessage)
                    }
                }
                
            }
    }
}
    

