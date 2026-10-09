//
//  RecipeService.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 7/12/25.
//

import Foundation
import FirebaseAuth


//Protocol lets previews inject a sample data service instead of calling the backend. https://developer.apple.com/videos/play/wwdc2020/10149/
// around 22mins
protocol RecipeServiceProtocol {
    func getAllRecipes(user: User, completionHandler: @escaping (Result<[Recipe], Error>) -> Void)
    func generateRecipe(user: User, completionHandler: @escaping (Result<Void, Error>) -> Void)
}

struct RecipeService: RecipeServiceProtocol {
    static let shared = RecipeService()
    
    //Getting the list of recipes depending on user
    func getAllRecipes(user: User, completionHandler: @escaping (Result<[Recipe], Error>) -> Void) {
        
        user.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print(error)
                return;
            }
            let url = URL(string: "\(AppConfig.baseUrl)/getAllRecipes")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) {data, response, error in
                
                if let error = error{
                    completionHandler(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,

                        let data = data else {
                    print("Failed to Load Recipes")
                    return
                    
                }
                
                
                do {
                    let recipes = try JSONDecoder().decode([Recipe].self, from: data)
                    completionHandler(.success(recipes))
                }
                
                catch {
                    print(error)
                }
            }
            task.resume()
        }
    }
    
    func generateRecipe(user: User, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        
        user.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print(error)
                return;
            }
            let url = URL(string: "\(AppConfig.baseUrl)/generateRecipe")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) {data, response, error in
                if let error = error{
                    completionHandler(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                      
                        let data = data else {
                    print("Failed to Generate Recipes")
                    return
                    
                }
                
                completionHandler(.success(()))
                           
            }
            task.resume()
        }
    }
    
}
