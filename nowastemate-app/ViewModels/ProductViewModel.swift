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

enum IngredientAvailability {
    case owned
    case missing
    case unknown
}

class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var errorMessage: String?
    @Published var hasLoadedProducts = false


    // compactMap allows for nil items to be in the list
    // https://developer.apple.com/documentation/swift/sequence/compactmap(_:)
    private var ownedProductIds: Set<String> {
        Set(products.compactMap { $0.id })
    }

    func loadProducts(for user: User){

        ProductService.shared.getProducts(user: user) {result in
            switch result {
            case .success(let products):
                self.products = products
                self.hasLoadedProducts = true
                self.errorMessage = nil
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            
            }
        }
    }
    
    // The view model is app-scoped instead of account levll, so it outlives sign out. Clear it to fix this carryover
    func resetProducts() {
        products = []
        errorMessage = nil
        hasLoadedProducts = false
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

    // A recipe stores the productId it was generated from, but that is just a snapshot,
    // so availability refreshes the check. Added guard for proper error checking as well.
    
    func availability(for ingredient: Ingredient) -> IngredientAvailability {
        guard hasLoadedProducts else { return .unknown }
        guard let productId = ingredient.productId, !productId.isEmpty else { return .missing }
        return ownedProductIds.contains(productId) ? .owned : .missing
    }


    func ownedIngredientCount(in ingredients: [Ingredient]) -> Int? {
        guard hasLoadedProducts else { return nil }
        return ingredients.filter { availability(for: $0) == .owned }.count
    }
}
