//
//  Family.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 30/11/2025.
//

struct Family: Codable {

    var title: String
    //https://stackoverflow.com/questions/46814313/ignore-non-codable-optional-properties-in-codable-object
    var ownerId: String? = nil
    
}
