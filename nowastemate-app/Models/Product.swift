//
//  Product.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2025-11-27.
//

import Foundation

struct Product: Identifiable, Codable {
    var id: String?
    var name: String
    var quantity: Int
    var createdAt: String
    var createdBy: String?
    var dateExpiredUserSet: String?
    var dateRemoved: String?
    var usedInRecipe: String?
    var category: String
}

