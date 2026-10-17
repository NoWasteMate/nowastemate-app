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
    // only false until the first load so reloads don't blank the list. Aligned with hasLoadedProducts now
    var hasLoadedRecipes = false
    // Spins just the Generate button
    var isGenerating = false
    var errorMessage: String?
    //Lets previews (& future unit tests) pass a mock service with sample data + defaults to the .shared version for the app
    // https://www.swiftbysundell.com/articles/mocking-in-swift/
    private let service: RecipeServiceProtocol

    init(service: RecipeServiceProtocol = RecipeService.shared) {
        self.service = service
    }

    func loadRecipes(for user: User){
        service.getAllRecipes(user: user) {result in
            DispatchQueue.main.async {
                if case .success(let recipes) = result {
                    self.recipes = recipes
                    self.hasLoadedRecipes = true
                }
            }
        }
    }
    
    func generateRecipe(for user: User, productIds: [String]){
        self.isGenerating = true

        service.generateRecipe(user: user, productIds: productIds) {result in
            DispatchQueue.main.async {
                self.isGenerating = false
                if case .success = result {
                    self.loadRecipes(for: user)
                }
            }
        }
    }

    func deleteRecipe(for user: User, recipe: Recipe) {
        service.deleteRecipe(user: user, recipeId: recipe.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.recipes.removeAll { $0.id == recipe.id }
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func resetRecipes() {
        recipes = []
        hasLoadedRecipes = false
        isGenerating = false
        errorMessage = nil
    }
}
