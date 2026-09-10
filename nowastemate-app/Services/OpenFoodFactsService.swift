//
//  OpenFoodFactsService.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2026-09-10.
//

import Foundation

// references:
// https://openfoodfacts.github.io/documentation/docs/Product-Opener/api/
// https://openfoodfacts.github.io/openfoodfacts-server/api/ref-v2/
// https://developer.apple.com/documentation/swift/decodable


struct OpenFoodFactsService {
    static let shared = OpenFoodFactsService()
    
    private let baseUrl = URL(string: "https://world.openfoodfacts.org/api/v2/product")!
    
    // fall back error
    enum error: Error {
        case notFound
    }
    
    // the response fields
    private struct OpenFoodFactsResponse: Decodable {
        let status: Int
        let product: OpenFoodFactsProduct?
    }

    private struct OpenFoodFactsProduct: Decodable {
        let code: String?
        let product_name: String?
        let categories_tags: [String]?
    }
    
    //@TODO GET method functionality
}
