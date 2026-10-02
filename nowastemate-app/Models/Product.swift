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

enum ProductOutcome: String, Codable {
    case active
    case consumed
    case usedInRecipe
    case wasted
    
    // same as product category
    init(from decoder: Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(String.self)
        self = ProductOutcome(rawValue: rawValue) ?? .active
    }
}

// reference for displayName (computed property): https://docs.swift.org/swift-book/documentation/the-swift-programming-language/properties/#Computed-Properties
// reference for switching on self in an enum: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/enumerations/
enum WasteReason: String, Codable, CaseIterable, Identifiable {
    case expired
    case spoiledEarly
    case boughtTooMuch
    case other

    var id: String { rawValue }

    // rawValue.capitalized would show "Spoiledearly", so each case gets its own label
    var displayName: String {
        switch self {
        case .expired: return "Expired"
        case .spoiledEarly: return "Spoiled early"
        case .boughtTooMuch: return "Bought too much"
        case .other: return "Other"
        }
    }

    // same as product category: unknown values fall back to other
    init(from decoder: Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(String.self)
        self = WasteReason(rawValue: rawValue) ?? .other
    }
}

struct Product: Identifiable, Codable {
    var id: String?
    var name: String
    var quantity: Int
    var createdAt: String
    var createdBy: String?
    var dateExpiration: String?
    //var dateRemoved: String?
    //var usedInRecipe: String?
    var category: ProductCategory?
    var outcome: ProductOutcome?
    var outcomeAt: String?
    var wasteReason: WasteReason?
}

