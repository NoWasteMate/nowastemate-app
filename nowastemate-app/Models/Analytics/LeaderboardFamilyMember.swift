//
//  LeaderboardFamilyMember.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 15/11/2026.
//

struct LeaderboardFamilyMember: Codable, Hashable, Identifiable {
    var id: String
    var firstName: String
    var lastName: String
    var score: Int?
}
