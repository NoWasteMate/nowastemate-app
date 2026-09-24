//
//  FamilyService.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 30/11/2025.
//


import Foundation
import FirebaseAuth

//Protocol lets previews inject a sample data service instead of calling the backend. https://developer.apple.com/videos/play/wwdc2020/10149/
// around 22mins

//resource on completionHandler https://medium.com/@kalidoss.shanmugam/swift-completion-handlers-an-overview-bd6e62251f1d

protocol FamilyServiceProtocol {
    
    func postFamily(title: String, completionHandler: @escaping (Result<String, Error>) -> Void)
    func joinFamily(code: String, completionHandler: @escaping (Result<String, Error>) -> Void)
    func getFamilyId(completionHandler: @escaping (Result<[String], Error>) -> Void)
    func getFamilyMembers(completionHandler: @escaping (Result<[FamilyMember], Error>) -> Void)
    func getFamily(completionHandler: @escaping (Result<Family, Error>) -> Void)
    func updateFamilyName(title: String, completionHandler: @escaping (Result<String, Error>) -> Void)
    func updateOwner(member: FamilyMember, completionHandler: @escaping (Result<String, Error>) -> Void)
    func deleteFamilyMembership(member: FamilyMember, completionHandler: @escaping (Result<String, Error>) -> Void)
    func deleteOwnMembership(member: FamilyMember, completionHandler: @escaping (Result<String, Error>) -> Void)

}

struct FamilyService: FamilyServiceProtocol {
    static let shared = FamilyService()
    
    var currentUser: User? {
        Auth.auth().currentUser
    }
    
    
    
    func postFamily(title: String, completionHandler: @escaping (Result<String, Error>) -> Void){
        print("service called")
        //logic for API call
        currentUser!.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            print(error)
            return;
          }
            let url = URL(string: "\(AppConfig.baseUrl)/family")!
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
                
                completionHandler(.success(title))
                
            }
            task.resume()
        }
    }
    
    
    func joinFamily(code: String, completionHandler: @escaping (Result<String, Error>) -> Void){
        //retrieve familyid and logic for API call
        print("service called")
        //logic for API call
        currentUser!.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            print(error)
            return;
          }
            let url = URL(string: "\(AppConfig.baseUrl)/family/join")!
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
                completionHandler(.success(code))
            }
            task.resume()
        }
    }
    
    
    
    //https://lukerobertsapps.medium.com/how-to-fetch-data-from-an-api-in-swift-d2ed6d9481a
    func getFamilyId(completionHandler: @escaping (Result<[String], Error>) -> Void){
        currentUser!.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            print(error)
            return;
          }
            let url = URL(string: "\(AppConfig.baseUrl)/family_id")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) {data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                do {
                    
                    let code = try JSONDecoder().decode([String].self, from: data)
                              completionHandler(.success(code))
                }
                
                catch {
                    print(error)
                    
                }
            }
            task.resume()
            
        }
    }
    
    func getFamily(completionHandler: @escaping (Result<Family, Error>) -> Void){
        currentUser!.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            print(error)
            return;
          }
            let url = URL(string: "\(AppConfig.baseUrl)/family")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) {data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                do {
                    let family = try JSONDecoder().decode(Family.self, from: data)
                    completionHandler(.success(family))
                }
                
                catch {
                    print(error)
                    completionHandler(.failure(error))
                }
            }
            task.resume()

        }
        
    }
    
    
    
    
    func getFamilyMembers(completionHandler: @escaping (Result<[FamilyMember], Error>) -> Void){
        currentUser!.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            print(error)
            return;
          }
            let url = URL(string: "\(AppConfig.baseUrl)/family_members")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) {data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                do {
                    let members = try JSONDecoder().decode([FamilyMember].self, from: data)
                              completionHandler(.success(members))
                }
                
                catch {
                    print(error)
                    completionHandler(.failure(error))
                }
            }
            task.resume()

        }
        
    }
    
    func updateFamilyName(title: String, completionHandler: @escaping (Result<String, Error>) -> Void){
        //logic for API call
        currentUser!.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            print(error)
            return;
          }
            let url = URL(string: "\(AppConfig.baseUrl)/family_name")!
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
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
            
            let task = URLSession.shared.dataTask(with: request) {data, response, error in
                guard let data = data, error == nil else {
                    completionHandler(.failure(error!))
                    return
                }
                
                //github.com/alexpaul/UIKit/blob/main/URLSession-Cheatsheet.md
                guard let httpResponse = response as? HTTPURLResponse,
                            (200...299).contains(httpResponse.statusCode) else {
                        print("Error occured")
                        return
                }
                //TODO: Network error handling and displaying to client

                completionHandler(.success(title))
                
                
            }
            task.resume()
        }
    }
    
    func updateOwner(member: FamilyMember, completionHandler: @escaping (Result<String, Error>) -> Void){
        //logic for API call
        currentUser!.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            print(error)
            return;
          }
            let url = URL(string: "\(AppConfig.baseUrl)/family_owner")!
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            //https://codesignal.com/learn/courses/basics-of-http-requests-with-swift/lessons/sending-data-with-post-requests-in-swift
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                        
            let encoder = JSONEncoder()
            do {
                request.httpBody = try encoder.encode(member)
            } catch {
                print("Failed to encode object: \(error)")
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) {data, response, error in
                guard let data = data, error == nil else {
                    completionHandler(.failure(error!))
                    return
                }
                
                //github.com/alexpaul/UIKit/blob/main/URLSession-Cheatsheet.md
                guard let httpResponse = response as? HTTPURLResponse,
                            (200...299).contains(httpResponse.statusCode) else {
                        print("Error occured")
                        return
                }
                //TODO: Network error handling and displaying to client

                completionHandler(.success(member.member))
                
                
            }
            task.resume()
        }
    }
    
    func deleteFamilyMembership(member: FamilyMember, completionHandler: @escaping (Result<String, Error>) -> Void){
        //logic for API call
        currentUser!.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            print(error)
            return;
          }
            let url = URL(string: "\(AppConfig.baseUrl)/family_member")!
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            //https://codesignal.com/learn/courses/basics-of-http-requests-with-swift/lessons/sending-data-with-post-requests-in-swift
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                        
            let encoder = JSONEncoder()
            do {
                request.httpBody = try encoder.encode(member)
            } catch {
                print("Failed to encode object: \(error)")
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) {data, response, error in
                guard let data = data, error == nil else {
                    completionHandler(.failure(error!))
                    return
                }
                
                //github.com/alexpaul/UIKit/blob/main/URLSession-Cheatsheet.md
                guard let httpResponse = response as? HTTPURLResponse,
                            (200...299).contains(httpResponse.statusCode) else {
                        print("Error occured")
                        return
                }
                //TODO: Network error handling and displaying to client

                completionHandler(.success(member.member))
                
                
            }
            task.resume()
        }
    }
    
    func deleteOwnMembership(member: FamilyMember, completionHandler: @escaping (Result<String, Error>) -> Void){
        //logic for API call
        currentUser!.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            print(error)
            return;
          }
            let url = URL(string: "\(AppConfig.baseUrl)/leave_family")!
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            //https://codesignal.com/learn/courses/basics-of-http-requests-with-swift/lessons/sending-data-with-post-requests-in-swift
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                        
            let encoder = JSONEncoder()
            do {
                request.httpBody = try encoder.encode(member)
            } catch {
                print("Failed to encode object: \(error)")
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) {data, response, error in
                guard let data = data, error == nil else {
                    completionHandler(.failure(error!))
                    return
                }
                
                //github.com/alexpaul/UIKit/blob/main/URLSession-Cheatsheet.md
                guard let httpResponse = response as? HTTPURLResponse,
                            (200...299).contains(httpResponse.statusCode) else {
                        print("Error occured")
                        return
                }
                //TODO: Network error handling and displaying to client

                completionHandler(.success(member.member))
                
                
            }
            task.resume()
        }
    }
    
}
