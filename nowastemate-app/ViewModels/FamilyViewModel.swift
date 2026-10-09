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
    
    var hasFamily: Bool {
        family != nil
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
    
    func createFamily(for user: User, title: String){
        
        service.postFamily(user: user, title: title) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    self.errorMessage = nil
                    //ensure UI is updated with new name
                    self.findFamilyMembers(for: user)
                    self.findExistingFamily(for: user)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func findNewFamily(for user: User, code: String){
        
        service.joinFamily(user: user, code: code){ result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    self.errorMessage = nil
                    //ensure UI is updated with new name
                    self.findFamilyMembers(for: user)
                    self.findExistingFamily(for: user)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func findFamilyId(for user: User){
            // Update UI
            //https://medium.com/@ankuriosdev/mastering-advanced-json-decoding-in-swift-part-2-74d5a956dd0a - Based on this
            self.service.getFamilyId(user: user) { result in
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
    
    func findFamilyMembers(for user: User){
            // Update UI
            //https://medium.com/@ankuriosdev/mastering-advanced-json-decoding-in-swift-part-2-74d5a956dd0a - Based on this
            self.service.getFamilyMembers(user: user) { result in
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
    
    func findExistingFamily(for user: User){
            self.service.getFamily(user: user) { result in
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
    
    func editFamilyName(for user: User, title: String){
            self.service.updateFamilyName(user: user, title: title) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let success):
                        self.errorMessage = nil
                        //ensure UI is updated with new name
                        self.findExistingFamily(for: user)
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        
    }
    
    func transferOwner(for user: User, member: FamilyMember){
            self.service.updateOwner(user: user, member: member) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let success):
                        self.errorMessage = nil
                        //ensure UI is updated with new name
                        self.findExistingFamily(for: user)
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    
    func removeFamilyMembership(for user: User, member: FamilyMember){
            self.service.deleteFamilyMembership(user: user, member: member) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let success):
                        self.errorMessage = nil
                        //ensure UI is updated with new name
                        self.findFamilyMembers(for: user)
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    
    func leaveFamily(for user: User, member: FamilyMember){
                self.service.deleteOwnMembership(user: user, member: member) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let success):
                            self.errorMessage = nil
                            //ensure UI is updated with new name
                            self.family = nil
                            self.familyMembers = nil
                        case .failure(let error):
                            self.errorMessage = error.localizedDescription
                        }
                    }
                }
            }
            
}
