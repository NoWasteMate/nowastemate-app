//
//  WasteRisk.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 2026-11-16.
//

import Foundation

enum WasteRisk: String, Codable {
    case low
    case medium
    case high
}

struct ProductWasteRisk: Codable, Identifiable {
    let id: String
    let name: String
    let productType: String?
    let dateExpiration: String?
    let risk: WasteRisk
    // True when the user's category waste raised the risk
    let categoryOftenWasted: Bool
}
