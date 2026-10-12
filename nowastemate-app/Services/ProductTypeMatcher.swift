//
//  ProductTypeMatcher.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 2026-10-09.
//

import Foundation
import FuzzyMatch

// Searches names and synonyms, then maps matches back to Product Types
// https://github.com/ordo-one/FuzzyMatch/blob/1.4.0/Examples/FuzzySearch/FuzzySearch/SearchViewModel.swift
struct ProductTypeMatcher {
    private let matcher = FuzzyMatcher()
    private var candidateNames: [String] = []
    // i.e. "spring onion", "green onion" and "scallions" all point at the spring-onion type
    private var typesByName: [String: ProductType] = [:]

    // FuzzyMatch only gives back the text that matched, so names and synonyms both point at their type
    init(types: [ProductType]) {
        for type in types {
            for name in [type.name] + type.synonyms {
                // Same as the example: if two types share a name, the first one keeps it
                if typesByName[name] == nil {
                    typesByName[name] = type
                    candidateNames.append(name)
                }
            }
        }
    }

    func suggestions(for text: String, limit: Int = 3) -> [ProductType] {
        // Since FuzzyMatch treats an empty query as a perfect match for everything, so an empty field would show random types
        // https://github.com/ordo-one/FuzzyMatch/tree/1.4.0
        if text.isEmpty { return [] }

        let query = matcher.prepare(text)
        let topMatches = matcher.topMatches(candidateNames, against: query, limit: limit)

        // "egg" and "eggs" can both match the egg type, so show it once
        var suggestions: [ProductType] = []
        for result in topMatches {
            guard let type = typesByName[result.candidate] else { continue }
            if suggestions.contains(where: { $0.key == type.key }) { continue }
            suggestions.append(type)
        }
        return suggestions
    }
}
