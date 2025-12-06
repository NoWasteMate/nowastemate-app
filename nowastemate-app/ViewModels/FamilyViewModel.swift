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
    
    @Published var familyId: String?
    
    @Published var errorMessage: String?
    
    //specifically grab userid as it is all that is needed
    let currentUser = Auth.auth().currentUser
    
    func createFamily(title: String){
        
        FamilyService.shared.postFamily(title: title)
        
    }
    
    func findFamily(code: String){
        
        FamilyService.shared.joinFamily(code: code)
    }
    
    func findFamilyId(){
        
        DispatchQueue.main.async {
            // Update UI
            //https://medium.com/@ankuriosdev/mastering-advanced-json-decoding-in-swift-part-2-74d5a956dd0a - Based on this
            FamilyService.shared.getFamilyId() { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let familyId):
                        self.familyId = familyId.first!
                        self.errorMessage = nil
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.familyId = nil
                    }
                }
            }
        }
    }
}
