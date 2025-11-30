//
//  FamilyViewModel.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 30/11/2025.
//

import Foundation
import Combine
import FirebaseAuth

class FamilyViewModel: ObservableObject {
    
    @Published var Temp: String = ""
    
    init() {
        self.Temp = "Test"
    }
    
    //TODO:
    
    func createFamily(family: Family){
        
    }
    
    func findFamily(){
        
    }
    
}
