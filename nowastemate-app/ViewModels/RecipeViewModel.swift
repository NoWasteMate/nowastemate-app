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

class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var errorMessage: String?
    
    func loadRecipes(){
        RecipeService.shared.getAllRecipes() {result in
            DispatchQueue.main.async {
                switch result {
                case .success(let recipes):
                    self.recipes = recipes
                case .failure:
                    return
                }
                
            }
        }
    }
    
    func generateRecipe(){
        
    }
}
