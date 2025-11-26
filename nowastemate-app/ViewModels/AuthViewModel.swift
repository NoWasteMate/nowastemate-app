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

    init() {
        self.user = Auth.auth().currentUser
        self.isSignedIn = user != nil
    }

    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Sign Up Error: \(error.localizedDescription)")
                return
            }
            self.user = result?.user
            self.isSignedIn = true
        }
    }
    
    func signIn(email: String, password: String) {
        print("Signing in user: \(email)")
         Auth.auth().signIn(withEmail: email, password: password) { result, error in
             if let error = error {
                 print("Sign In Error: \(error.localizedDescription)")
                 return
             }
             self.user = result?.user
             self.isSignedIn = true
         }
     }
    
     func signOut() {
         do {
             try Auth.auth().signOut()
             self.user = nil
             self.isSignedIn = false
             print("Signing Out...")
         } catch {
             print("Sign Out Error: \(error.localizedDescription)")
         }
     }
}

