//
//  Recipe.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 7/12/25.
//

import Foundation

enum RecipeCategory: String, Codable {
    case soup
    case salad
    case pasta
    case handheld
    case breakfast
    case dessert
    case drink
    case platedMain
    case general
}

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
    let category: RecipeCategory?
}
