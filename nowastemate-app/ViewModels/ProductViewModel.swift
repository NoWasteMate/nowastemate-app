//
//  ProductViewModel.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2025-11-27.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Combine

class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var errorMessage: String?
    
    func loadProducts(for user: User){

        ProductService.shared.getProducts(user: user) {result in
            switch result {
            case .success(let products):
                self.products = products
            case .failure:
                return
            
            }
        }
    }
    
    // The view model is app-scoped instead of account levll, so it outlives sign out. Clear it to fix this carryover
    func resetProducts() {
        products = []
        errorMessage = nil
    }

    func addProducts(for user: User, product: Product) {
        
        ProductService.shared.addProduct(user: user, product: product) { result in
            switch result {
            case .success(let products):
                self.products = products
                self.errorMessage = nil
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
            
        }
    }

}
