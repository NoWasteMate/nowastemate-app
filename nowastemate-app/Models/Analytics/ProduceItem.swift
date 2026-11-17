//
//  ProduceItem.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 16/11/2026.
//

import Foundation

struct ProduceItem: Codable {
    var predictedProduce: String
    var chosenProduce: String
    var createdBy: String?
    var createdAt: Date?
}
