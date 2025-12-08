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
        print(recipes)
        
        RecipeService.shared.getAllRecipes() {result in
            switch result {
            case .success(let recipes):
                self.recipes = recipes
//                print(recipes)
            case .failure:
                return
                
            }
        }
    }
}
