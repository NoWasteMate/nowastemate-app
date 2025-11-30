//
//  ProductService.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2025-11-27.
//

//References:
// https://gurjit-singh.medium.com/how-to-use-completion-handler-in-swift-d1c26b30c67
// https://www.hackingwithswift.com/quick-start/concurrency/how-to-use-continuations-to-convert-completion-handlers-into-async-functions

import Foundation
import FirebaseAuth

struct ProductService {
    static let shared = ProductService()
    
    let baseUrl = URL(string: "http://127.0.0.1:8000")!
    
    //Getting the list of products depending on user
    func getProducts(user: User, completion: @escaping (Result<[Product], Error>) -> Void){
        user.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            print(error)
            return;
          }
            let url = URL(string: "\(baseUrl)/getProducts")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) {data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                do {
                    //let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    //print(response)
                    
                    let products = try JSONDecoder().decode([Product].self, from: data)
                    print(products)
                    completion(.success(products))

                }
                
                catch {
                    print(error)
                }
            }
            task.resume()

        }
        
    }
    
}
