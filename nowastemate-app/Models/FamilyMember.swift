//
//  FamilyMember.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 19/09/2026.
//

import Foundation

struct FamilyMember: Codable, Hashable {
    var member: String
    var email: String? = nil
    var firstName: String? = nil
}
