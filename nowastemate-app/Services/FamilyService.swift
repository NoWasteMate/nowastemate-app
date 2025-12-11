//
//  FamilyService.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 30/11/2025.
//


import Foundation
import FirebaseAuth

struct FamilyService {
    static let shared = FamilyService()
    
    let baseUrl = URL(string: "http://127.0.0.1:8000")!
    
    var currentUser: User? {
        Auth.auth().currentUser
    }
    
    
    
    func postFamily(title: String){
        print("service called")
        //logic for API call
        currentUser!.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            print(error)
            return;
          }
            let url = URL(string: "\(baseUrl)/family")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            //https://codesignal.com/learn/courses/basics-of-http-requests-with-swift/lessons/sending-data-with-post-requests-in-swift
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let newFamily = Family(title: title)
            
            let encoder = JSONEncoder()
            do {
                request.httpBody = try encoder.encode(newFamily)
            } catch {
                print("Failed to encode object: \(error)")
                return
            }
            
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
    
    
    func joinFamily(code: String){
        //retrieve familyid and logic for API call
        print("service called")
        //logic for API call
        currentUser!.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            print(error)
            return;
          }
            let url = URL(string: "\(baseUrl)/family/join")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            //https://codesignal.com/learn/courses/basics-of-http-requests-with-swift/lessons/sending-data-with-post-requests-in-swift
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let newMember = FamilyJoinCode(code: code)
            
            let encoder = JSONEncoder()
            do {
                request.httpBody = try encoder.encode(newMember)
            } catch {
                print("Failed to encode object: \(error)")
                return
            }
            
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
    
    
    
    //https://lukerobertsapps.medium.com/how-to-fetch-data-from-an-api-in-swift-d2ed6d9481a
    func getFamilyId(completion: @escaping (Result<[String], Error>) -> Void){
        currentUser!.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            print(error)
            return;
          }
            let url = URL(string: "\(baseUrl)/family_id")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) {data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                do {
                    
                    let code = try JSONDecoder().decode([String].self, from: data)
                              completion(.success(code))
                }
                
                catch {
                    print(error)
                    
                }
            }
            task.resume()
            
        }
    }
    
    
    
    
    func getFamilyMembers(completion: @escaping (Result<[String], Error>) -> Void){
        currentUser!.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            print(error)
            return;
          }
            let url = URL(string: "\(baseUrl)/family_members")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) {data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                do {
                    let code = try JSONDecoder().decode([String].self, from: data)
                              completion(.success(code))
                }
                
                catch {
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()

        }
        
    }
    
}
