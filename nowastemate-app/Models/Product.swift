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
    case forgot
    case badQuality
    case storedWrong
    case other
    case addedByMistake


    var id: String { rawValue }

    // rawValue.capitalized would show "Spoiledearly", so each case gets its own label
    var displayName: String {
        switch self {
        case .expired: return "Product Expired"
        case .spoiledEarly: return "Product Spoiled Early"
        case .boughtTooMuch: return "I Bought Too Much"
        case .forgot: return "Forgot about Product"
        case .badQuality: return "Product Arrived Bad"
        case .storedWrong: return "Product Stored Incorrectly"
        case .other: return "Other"
        case .addedByMistake: return "Added by Mistake"
        }
    }

    // same as product category: unknown values fall back to other
    init(from decoder: Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(String.self)
        self = WasteReason(rawValue: rawValue) ?? .other
    }
}

// reference: https://developer.apple.com/documentation/foundation/iso8601dateformatter
// reference: https://developer.apple.com/documentation/foundation/calendar/startofday(for:)
enum ExpiryStatus {
    case expired
    case today
    case tomorrow
    case soon
    case fresh
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
    var productType: String?
    var productTypeSource: String?
    var categoryTags: [String]?
    var outcome: ProductOutcome?
    var outcomeAt: String?
    var wasteReason: WasteReason?
}

// reference: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/extensions/
extension Product {
    
    // dateExpiration is an ISO 8601 string so the backend can send it with or without fractional seconds
    private var expiryDate: Date? {
        guard let dateExpiration else { return nil }
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateExpiration) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: dateExpiration)
    }
    
    // whole calendar days so 11 pm tomorrow still counts as 1 day away
    func daysUntilExpiry(now: Date = .now) -> Int? {
        guard let expiryDate else { return nil }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: now)
        let end = calendar.startOfDay(for: expiryDate)
        return calendar.dateComponents([.day], from: start, to: end).day
    }
    
    // near expiry is three or fewer days away expired once the date has passed
    func expiryStatus(now: Date = .now) -> ExpiryStatus {
        guard let days = daysUntilExpiry(now: now) else { return .fresh }
        switch days {
        case ..<0: return .expired
        case 0: return .today
        case 1: return .tomorrow
        case 2...3: return .soon
        default: return .fresh
        }
    }
}
