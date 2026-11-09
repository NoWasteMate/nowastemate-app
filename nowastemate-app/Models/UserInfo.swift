//
//  User.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 08/09/2026.
//

struct UserInfo: Codable {
    var email: String
    var firstName: String
    var lastName: String
    var dietaryRestrictions: String
    var notificationDays: Int?
    var notificationHour: Int?
}
//https://www.reddit.com/r/BlossomBuild/comments/1nr1frc/make_your_swift_enums_identifiable/
enum DietaryRestrictions: String, Codable, CaseIterable, Identifiable {
    
    var id: String { rawValue }
    
    case egg = "Egg"
    case fish = "Fish"
    case keto = "Keto"
    case milk = "Milk"
    case mustard = "Mustard"
    case paleo = "Paleo"
    case peanut = "Peanut"
    case pescetarian = "Pescetarian"
    case raw = "Raw"
    case shellfish = "Shellfish"
    case soy = "Soy"
    case sugar = "Sugar"
    case sulphite = "Sulphite"
    case tree_nut = "Tree Nut"
    case vegan = "Vegan"
    case vegetarian = "Vegetarian"
    case wheat = "Wheat"
    

}
