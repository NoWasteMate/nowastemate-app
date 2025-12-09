//
//  RecipeService.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 7/12/25.
//

import Foundation
import FirebaseAuth


struct RecipeService {
    static let shared = RecipeService()
    
    let baseUrl = URL(string: "http://127.0.0.1:8000")!
    
    var currentUser: User? {
        Auth.auth().currentUser
    }
    
    //Getting the list of recipes depending on user
    func getAllRecipes(completion: @escaping (Result<[Recipe], Error>) -> Void) {
        
        currentUser!.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print(error)
                return;
            }
            let url = URL(string: "\(baseUrl)/getAllRecipes")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) {data, response, error in
                
                if let error = error{
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,

                        let data = data else {
                    print("Failed to Load Recipes")
                    return
                    
                }
                
                
                do {
                    let recipes = try JSONDecoder().decode([Recipe].self, from: data)
                    completion(.success(recipes))
                }
                
                catch {
                    print(error)
                }
            }
            task.resume()
        }
    }
    
    func generateRecipe(completion: @escaping (Result<Void, Error>) -> Void) {
        
        currentUser!.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print(error)
                return;
            }
            let url = URL(string: "\(baseUrl)/generateRecipe")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) {data, response, error in
                if let error = error{
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                      
                        let data = data else {
                    print("Failed to Load Recipes")
                    return
                    
                }
                
                completion(.success(()))
                           
            }
            task.resume()
        }
    }
    
}
