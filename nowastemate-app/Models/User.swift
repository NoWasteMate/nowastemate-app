//
//  User.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 15/11/2025.
//

import Foundation

struct User: Identifiable, Codable {
    let id = UUID()
    var firstName: String
    var lastName: String
    var password: String
    
    //TODO: logging for user to observe timestamps for creation and modification
    //let createDate = Date()
    //var modifiedDate: Date
    //TODO: Add later
    //var productList: [Product]
    //var recipeList: [Recipe]
}
