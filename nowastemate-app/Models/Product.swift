//
//  Product.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2025-11-27.
//

import Foundation

enum ProductCategory: String, Codable {
    case produce
    case dairy
    case meat
    case grains
    case canned
    case frozen
    case beverage
    case other
}

struct Product: Identifiable, Codable {
    var id: String?
    var name: String
    var quantity: Int
    var createdAt: String
    var createdBy: String?
    var dateExpiration: String?
    var dateRemoved: String?
    var usedInRecipe: String?
    var category: ProductCategory?
}

