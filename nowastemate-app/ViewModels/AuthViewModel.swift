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


//https://medium.com/@authfy/getting-started-with-swiftui-and-firebase-a-complete-guide-e7c25b7cd9c4


class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var isSignedIn: Bool = false
    @Published var loginError: Bool = false
    @Published var errorMessage: String?
    @Published var userInfo: UserInfo? = nil

    
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
        
    func signUp(email: String, password: String, firstName: String, lastName: String, dietaryRestrictions: String, completion: @escaping (Error?) -> Void = { _ in }) {
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
            }
        }
    }
        
    func logToken() async {
        await AuthService.shared.logAuthID()
        
    }
    
    func createUser(email: String, firstName: String, lastName: String, dietaryRestrictions: String) {
        
        
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
    
    func editRequest(email: String, firstName: String, lastName: String, dietaryRestrictions: String, completion: @escaping (Error?) -> Void = { _ in }){
            self.authService.editUser(email: email, firstName: firstName, lastName: lastName, dietaryRestrictions: dietaryRestrictions) { error in
                DispatchQueue.main.async {
                if let error = error {
                    print("Error:", error.localizedDescription)
                    completion(error)
                    return
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
    

