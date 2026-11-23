//
//  AddRecipeFeedbackRequest.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 2026-11-22.
//

import Foundation

enum Leftovers: String, Codable, CaseIterable {
    // Using noneLeft so it doesn't clash with Optional.none, backend still gets "none"
    case noneLeft = "none"
    case little
    case lots
}

struct AddRecipeFeedbackRequest: Codable {

    var productIds: [String]
    var makeAgain: Bool?
    var leftovers: Leftovers?

}
