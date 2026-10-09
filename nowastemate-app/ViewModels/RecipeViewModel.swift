//
//  RecipeViewModel.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 7/12/25.
//


import Foundation
import SwiftUI
import FirebaseAuth
import Combine

// https://medium.com/@minalkewat/modern-mvvm-in-swiftui-2025-the-clean-architecture-youve-been-waiting-for-72a7d576648e
// Updated to newer architecture for observable view models
@Observable
final class RecipeViewModel: ObservableObject {
    var recipes: [Recipe] = []
    var isLoading = false
    var errorMessage: String?
    //Lets previews (& future unit tests) pass a mock service with sample data + defaults to the .shared version for the app
    // https://www.swiftbysundell.com/articles/mocking-in-swift/
    private let service: RecipeServiceProtocol

    init(service: RecipeServiceProtocol = RecipeService.shared) {
        self.service = service
    }

    func loadRecipes(for user: User){
        self.isLoading = true

        service.getAllRecipes(user: user) {result in
            DispatchQueue.main.async {
                switch result {
                case .success(let recipes):
                    self.recipes = recipes
                    self.isLoading = false
                case .failure:
                    self.isLoading = false
                    return
                }
                self.isLoading = false
            }
        }
    }
    
    func generateRecipe(for user: User){
        self.isLoading = true

        service.generateRecipe(user: user) {result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.loadRecipes(for: user)
                    // loadRecipes() will call isLoading = false
                case .failure:
                    self.isLoading = false
                    return
                }
                
            }
        }
    }
}
