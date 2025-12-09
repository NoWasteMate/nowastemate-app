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
    
    
    func loadRecipes(){
        self.isLoading = true

        RecipeService.shared.getAllRecipes() {result in
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
    
    func generateRecipe(){
        self.isLoading = true

        RecipeService.shared.generateRecipe() {result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.loadRecipes()
                    // loadRecipes() will call isLoading = false
                case .failure:
                    self.isLoading = false
                    return
                }
                
            }
        }
    }
}
