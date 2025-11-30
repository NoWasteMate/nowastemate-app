//
//  Product.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2025-11-27.
//

import Foundation

struct Product: Identifiable, Codable {
    var id: String
    var name: String
    var quantity: Int
    var createdAt: String
    var category: String
}

