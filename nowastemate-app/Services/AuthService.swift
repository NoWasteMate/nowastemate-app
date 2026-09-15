//
//  AuthService.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 25/11/25.
//

// Firebase auth uses main thread, documentation recoomends callbacks. https://stackoverflow.com/questions/67941742/when-should-i-do-user-interface-work-on-the-main-thread-while-using-firebase
// Information on Firebase Auth Tokens: https://firebase.google.com/docs/auth/users#auth_tokens
// Retrieval of token code reference https://firebase.google.com/docs/auth/admin/verify-id-tokens#retrieve_id_tokens_on_clients

import Foundation
import FirebaseAuth

struct AuthService {
    static let shared = AuthService()
    
    var currentUser: User? {
        Auth.auth().currentUser
    }
    
    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Sign In Error: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            let user = result?.user
            print("Signed in as user: \(user?.uid ?? "not available")")
            completion(nil) // Tells view model the operation was successful, without this the state change was not occuring in viewmodel, ui not updating
        }
    }
    func signUp(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            let user = result?.user
            print("Signed up as: \(user?.email ?? "unknown user")")
            completion(nil)
        }
    }
    func signOut(completion: @escaping (Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            print("Signing out")
            completion(nil)
        }
        catch {
            completion(error)
        }
    }
    
    
    func getUserEmail(){
        Auth.auth().currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            print(error)
            return;
          }
            let url = URL(string: "\(AppConfig.baseUrl)/userInformation")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) {data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                do {
                    let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print(response)
                }
                
                catch {
                    print(error)
                }
            }
            task.resume()

        }
        
    }
    

    
    // MARK: Debug
    func logAuthID() async {
        do{
            let idToken = try await validToken()
            print("------------------------------")
            print(idToken)
            print("------------------------------")
        }
        catch{
            print("------------------------------")
            print("ERROR LOGGING TOKEN \(error)")
            print("------------------------------")
        }
    }
    
    // https://www.donnywals.com/migrating-callback-based-code-to-swift-concurrency-with-continuations/
    // Code sourced from here, example of working with token in an async context
    func validToken() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().currentUser?.getIDTokenForcingRefresh(true){ idToken, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    print("error validation user")
                }
                else{
                    continuation.resume(returning: idToken ?? "No token found")
                }
            }
        }
    }
    
    func syncUser(firstName: String, lastName: String, dietaryRestrictions: String){
        Auth.auth().currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            print(error)
            return;
          }
            let url = URL(string: "\(AppConfig.baseUrl)/syncUser")!
            var request = URLRequest(url: url)
            
            let newUser = UserInfo(firstName: firstName, lastName: lastName, dietaryRestrictions: dietaryRestrictions)
            
            let encoder = JSONEncoder()
            do {
                request.httpBody = try encoder.encode(newUser)
                print(request.httpBody!)
            } catch {
                print("Failed to encode object: \(error)")
                return
            }
            
            request.httpMethod = "POST"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let task = URLSession.shared.dataTask(with: request) {data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                do {
                    let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print(response)
                }
                
                catch {
                    print(error)
                }
            }
            task.resume()
        }
        
    }
}



