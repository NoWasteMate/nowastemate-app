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

    private var ownedProductNames: Set<String> {
        Set(products.map { normalizedName($0.name) })
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
    
    func deleteProduct(for user: User, product: Product) {
        ProductService.shared.deleteProduct(user: user, product: product) { result in
            switch result {
            case .success:
                self.products.removeAll { $0.id == product.id }
                self.errorMessage = nil
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    // A recipe stores the productId it was generated from, but that is just a snapshot and not updating based on live product availability
    func availability(for ingredient: Ingredient) -> IngredientAvailability {
        guard hasLoadedProducts else { return .unknown }

        let productId = ingredient.productId ?? ""
        let hasMatchingId = !productId.isEmpty && ownedProductIds.contains(productId)

        let ingredientName = normalizedName(ingredient.name)
        let hasMatchingName = ownedProductNames.contains(ingredientName)

        if hasMatchingId || hasMatchingName {
            return .owned
        }
        return .missing
        
    }
    
    // Normalize names so matching ignores capitalization, accents, and extra spaces provided by user.
    // https://stackoverflow.com/questions/25525171/uitextview-highlight-all-matches-using-swift
    private func normalizedName(_ name: String) -> String {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.folding(
            options: [.diacriticInsensitive, .caseInsensitive],
            locale: .current
        )
    }


    func ownedIngredientCount(in ingredients: [Ingredient]) -> Int? {
        guard hasLoadedProducts else { return nil }
        return ingredients.filter { availability(for: $0) == .owned }.count
    }
}
