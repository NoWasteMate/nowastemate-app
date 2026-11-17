//
//  GenerateRecipeRequest.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 2026-10-12.
//

import Foundation

struct GenerateRecipeRequest: Codable {

    var productIds: [String]
    var mealType: RecipeCategory?
    var difficulty: RecipeDifficulty?
    var maxTotalTime: Int?
    var servings: Int?
    var expiringFirst: Bool

}
