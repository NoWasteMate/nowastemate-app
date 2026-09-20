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
    
    @Published var family: Family?

    @Published var familyMembers: [FamilyMember]?
    
    @Published var errorMessage: String?
    
    var isOwner: Bool {
        family?.ownerId == currentUser?.uid && family?.ownerId != nil
    }
    

    //Lets previews (& future unit tests) pass a mock service with sample data + defaults to the .shared version for the app
    // https://www.swiftbysundell.com/articles/mocking-in-swift/
    private let service: FamilyServiceProtocol

    init(service: FamilyServiceProtocol = FamilyService.shared) {
        self.service = service
    }
    
    //specifically grab userid as it is all that is needed
    var currentUser: User? {
        Auth.auth().currentUser
    }
    
    func createFamily(title: String){
        
        service.postFamily(title: title)
        
    }
    
    func findNewFamily(code: String){
        
        service.joinFamily(code: code)
    }
    
    func findFamilyId(){
        
        DispatchQueue.main.async {
            // Update UI
            //https://medium.com/@ankuriosdev/mastering-advanced-json-decoding-in-swift-part-2-74d5a956dd0a - Based on this
            self.service.getFamilyId() { result in
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
    
    func findFamilyMembers(){
        DispatchQueue.main.async {
            // Update UI
            //https://medium.com/@ankuriosdev/mastering-advanced-json-decoding-in-swift-part-2-74d5a956dd0a - Based on this
            self.service.getFamilyMembers() { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let familyMembers):
                        self.familyMembers = familyMembers
                        self.errorMessage = nil
                        print(familyMembers)
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.familyMembers = nil
                    }
                }
            }
        }
    }
    
    func findExistingFamily(){
        DispatchQueue.main.async {
            self.service.getFamily() { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let family):
                        self.family = family
                        self.errorMessage = nil
                        print(family)
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.family = nil
                    }
                }
            }
        }
    }
    
    func editFamilyName(title: String){
        
        DispatchQueue.main.async {
            self.service.updateFamilyName(title: title) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let success):
                        self.errorMessage = nil
                        //ensure UI is updated with new name
                        self.findExistingFamily()
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    func transferOwner(member: FamilyMember){
        
        DispatchQueue.main.async {
            self.service.updateOwner(member: member) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let success):
                        self.errorMessage = nil
                        //ensure UI is updated with new name
                        self.findExistingFamily()
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    func removeFamilyMembership(member: FamilyMember){
        
        DispatchQueue.main.async {
            self.service.deleteFamilyMembership(member: member) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let success):
                        self.errorMessage = nil
                        //ensure UI is updated with new name
                        self.findFamilyMembers()
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
}
