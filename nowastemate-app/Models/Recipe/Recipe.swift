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
    let prepTime: Int
    let cookTime: Int
    let servings: Int
    let ingredients: [Ingredient]
    let instructions: [String]
    let createdAt: String
}
