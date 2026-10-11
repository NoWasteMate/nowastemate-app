//
//  WasteTrend.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2026-10-11.
//

// References:
// https://developer.apple.com/documentation/foundation/encoding-and-decoding-custom-types
// https://developer.apple.com/documentation/foundation/jsondecoder/datedecodingstrategy/iso8601
// https://developer.apple.com/documentation/swift/caseiterable
// https://developer.apple.com/documentation/swift/identifiable
// https://developer.apple.com/documentation/swift/codingkeyrepresentable
// https://github.com/swiftlang/swift-evolution/blob/main/proposals/0320-codingkeyrepresentable.md
// https://developer.apple.com/documentation/swift/sequence/compactmap(_:)
// https://developer.apple.com/documentation/swift/sequence/reduce(_:_:)


import Foundation

enum TrendPeriod: String, Codable, CaseIterable, Identifiable {
    case week
    case month
    
    var id : String { rawValue }
    
    var displayName : String {
        switch self {
        case .week: return "Week"
        case .month: return "Month"
        }
    }
}

struct WasteTrendInformation: Codable, Identifiable {
    let periodStart: Date
    let wastedCount: Int
    let consumedCount: Int
    
    // JSONDecoder only reads String : Int as JSON
    let byReason: [String : Int]
    
    var id : Date { periodStart }
    
    // chart segments per reason. Older wasted items have no wasteReason
    // "No reason is given" to ensure no errors
    
    // https://developer.apple.com/documentation/swift/sequence/compactmap(_:)
    var segments: [(label: String, count: Int)] {
        var result: [(label: String, count: Int)] = byReason.compactMap { key, value in
            guard let reason = WasteReason(rawValue: key), value > 0 else { return nil }
            return (reason.displayName, value)
        }
        let unrecorded = wastedCount - result.reduce(0) { $0 + $1.count }
        if unrecorded > 0 {
            result.append(("No reason given", unrecorded))
        }
        return result.sorted { $0.label < $1.label }
    }
}

struct WasteTrend: Codable {
    let period: TrendPeriod
    let information: [WasteTrendInformation]
    
    var totalWasted: Int { information.reduce(0) { $0 + $1.wastedCount } }
    var hasData: Bool { totalWasted > 0 }
}
