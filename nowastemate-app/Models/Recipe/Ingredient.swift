//
//  Ingredient.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 8/12/25.
//

import Foundation

struct Ingredient: Codable {
    // Lack of ID is by design. Ingredients will be accessed through index for display.
    let name: String
    var productId: String?
    let quantity: Double
    let unit: String
    var productType: String?
}
