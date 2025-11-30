//
//  FamilyService.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 30/11/2025.
//


import Foundation
import FirebaseAuth

struct FamilyService {
    static let shared = FamilyService()
    
    let baseUrl = URL(string: "http://127.0.0.1:8000")!
    
    
    func postFamily(family: Family){
        //logic for API call
        
    }
    
    
    func getFamily(){
        //retrieve familyid and logic for API call
        
    }
    
}
