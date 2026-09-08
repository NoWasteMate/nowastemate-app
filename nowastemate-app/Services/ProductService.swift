//
//  ProductService.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2025-11-27.
//

//References:
// https://gurjit-singh.medium.com/how-to-use-completion-handler-in-swift-d1c26b30c67
// https://www.hackingwithswift.com/quick-start/concurrency/how-to-use-continuations-to-convert-completion-handlers-into-async-functions
// https://www.hackingwithswift.com/forums/swift/help-needed-json-encoding/17744

import Foundation
import FirebaseAuth

struct ProductService {
    static let shared = ProductService()
    
    //Getting the list of products depending on user
    func getProducts(user: User, completion: @escaping (Result<[Product], Error>) -> Void){
        user.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            print(error)
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return;
          }
            let url = URL(string: "\(AppConfig.baseUrl)/getProducts")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) {data, _, error in
                guard let data = data, error == nil else {

                    DispatchQueue.main.async {
                        completion(.failure(error ?? URLError(.badServerResponse)))
                    }
                    return
                }
                do {
                    //let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    //print(response)
                    
                    let products = try JSONDecoder().decode([Product].self, from: data)
                    print(products)
                    DispatchQueue.main.async {
                        completion(.success(products))
                    }

                }
                
                catch {
                    print(error)
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
            task.resume()

        }
        
    }
    
    func addProduct(user: User, product: Product, completion: @escaping (Result<[Product], Error>) -> Void) {
        user.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print(error)
                return;
            }
            
            let url = URL(string: "\(AppConfig.baseUrl)/products")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            
            let encoder = JSONEncoder()
            
            do {
                request.httpBody = try encoder.encode(product)
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
    
    func deleteProduct(user: User, product: Product, completion: @escaping (Result<[Product], Error>) -> Void) {
        user.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print(error)
                return;
            }
            
            let url = URL(string: "\(AppConfig.baseUrl)/deleteProduct/\(product.id ?? "")")!
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
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
