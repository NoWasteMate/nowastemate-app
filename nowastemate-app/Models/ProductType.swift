//
//  ProductType.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 8/10/26.
//

import Foundation

// One entry from GET /productTypes, used for name suggestions and the "do I own this?" check
struct ProductType: Codable, Identifiable {
    let key: String
    let name: String
    let synonyms: [String]
    let parents: [String]
    let category: ProductCategory

    var id: String { key }
}

// upToDate comes back alone when the saved version is current, so the rest is optional
struct ProductTypeList: Codable {
    var upToDate: Bool?
    var version: Int?
    var types: [ProductType]?
}
