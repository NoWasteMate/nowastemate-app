//
//  Product.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2025-11-27.
//

import Foundation

// reference: https://developer.apple.com/documentation/swift/caseiterable
enum ProductCategory: String, Codable, CaseIterable {
    
    case produce
    case dairy
    case meat
    case grains
    case canned
    case frozen
    case beverage
    case other
    
    // there are issues when previous products that got added is strings so this defaults it to other
    // reference: https://developer.apple.com/documentation/swift/rawrepresentable
    init(from decoder: Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(String.self)
        self = ProductCategory(rawValue: rawValue) ?? .other
    }
    
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

