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
    
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case pescetarian = "Pescetarian"
    
    

}
