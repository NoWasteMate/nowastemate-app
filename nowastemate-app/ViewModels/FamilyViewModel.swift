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
    
    //specifically grab userid as it is all that is needed
    let currentUser = Auth.auth().currentUser
    
    
    
    
    init() {
        self.Temp = "Test"
    }
    
    func createFamily(title: String){
        
        FamilyService.shared.postFamily(title: title, user: currentUser!)
        
    }
    
    func findFamily(){
        
    }
    
}
