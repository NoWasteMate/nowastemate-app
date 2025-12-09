//
//  Recipe.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 7/12/25.
//

import Foundation

struct Recipe: Codable, Identifiable {
    let id: String
    let recipeName: String
    let description: String
    let prepTime: Int
    let cookTime: Int
    let servings: Int
    let difficulty: String
    let ingredientsUsed: Int
    let ingredients: [Ingredient]
    let instructions: [String]
    let createdAt: String
}
