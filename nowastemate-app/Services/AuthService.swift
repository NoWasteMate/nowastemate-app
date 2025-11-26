//
//  AuthService.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 25/11/25.
//

import Foundation
import FirebaseAuth

struct AuthService {
    static let shared = AuthService()
    
    let baseUrl = URL(string: "http://127.0.0.1:8000")!
    
    func getUserEmail(user: User){
        user.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            print(error)
            return;
          }
            let url = URL(string: "\(baseUrl)/userInformation")!
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
    
    // Information on Firebase Auth Tokens: https://firebase.google.com/docs/auth/users#auth_tokens
    // Retrieval of token code reference https://firebase.google.com/docs/auth/admin/verify-id-tokens#retrieve_id_tokens_on_clients
    func logAuthID(user: User) {
        user.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            print(error)
            return;
          }
          print(idToken ?? "")
        }
    }
}
