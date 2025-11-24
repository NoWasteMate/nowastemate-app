//
//  User.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 15/11/2025.
//

import Foundation

struct User: Codable {
    var first: String
    var last: String
    var email: String
    var password: String
    
    //TODO: logging for user to observe timestamps for creation and modification
    //let createDate = Date()
    //var modifiedDate: Date
    //TODO: Add later
    //var productList: [Product]
    //var recipeList: [Recipe]
}
