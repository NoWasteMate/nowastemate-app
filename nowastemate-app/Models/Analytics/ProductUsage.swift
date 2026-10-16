//
//  ProductUsage.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2026-10-16.
//

// References:
// https://developer.apple.com/documentation/foundation/encoding-and-decoding-custom-types
// https://developer.apple.com/documentation/swift/sequence/compactmap(_:)

import Foundation

struct ProductUsage: Codable {
    let days: Int?
    let consumedCount: Int
    let usedInRecipeCount: Int
    let wastedCount: Int
    let byReason: [String : Int]
    
    var total: Int { consumedCount + usedInRecipeCount + wastedCount }
    var hasData: Bool { total > 0 }
    
    // only outcomes are actually recorded, so usedInRecipe stays hidden while it is 0
    var slices: [(label: String, count: Int)] {
        [("Consumed", consumedCount), ("Used in recipe", usedInRecipeCount), ("Wasted", wastedCount)].filter { $0.1 > 0 }
    }
    
    // the same ideas as Waste Trend segments
    var wasteSegments: [(label: String, count: Int)] {
        var result: [(label: String, count: Int)] = byReason.compactMap { key, value in
            guard let reason = WasteReason(rawValue: key), value > 0 else { return nil }
            return (reason.displayName, value)
        }
        let unrecorded = wastedCount - result.reduce(0) { $0 + $1.count }
        if unrecorded > 0 {
            result.append(("No reason given", unrecorded))
        }
        return result.sorted { $0.count > $1.count }
    }
}
