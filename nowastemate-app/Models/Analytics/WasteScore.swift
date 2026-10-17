//
//  WasteScore.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 2026-10-16.
//

import Foundation

enum WasteRating: String, Codable {
    case needsWork
    case fair
    case good
    case great
    case excellent

    var displayName: String {
        switch self {
        case .needsWork: return "Needs work"
        case .fair: return "Fair"
        case .good: return "Good"
        case .great: return "Great"
        case .excellent: return "Excellent"
        }
    }

    // Asset catalog colour that tints the score circle and overview background
    var colorName: String {
        switch self {
        case .needsWork: return "WasteScoreNeedsWork"
        case .fair: return "WasteScoreFair"
        case .good: return "WasteScoreGood"
        case .great: return "WasteScoreGreat"
        case .excellent: return "WasteScoreExcellent"
        }
    }
}

// score fields stay nil until productsNeeded reaches 0
struct WasteScore: Codable {
    let score: Int?
    let rating: WasteRating?
    let wasteRatePoints: Int?
    let avoidablePoints: Int?
    let wasteRate: Double?
    let wasted: Int?
    let avoidableWasted: Int?
    let averageWasteRate: Double?
    let averageScore: Int?
    let productsNeeded: Int
}

struct WasteScoreSummary: Codable {
    let user: WasteScore
    let family: WasteScore?
}
