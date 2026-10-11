//
//  ProductViewModel.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2025-11-27.
//

// references: https://developer.apple.com/documentation/swift/array
// https://developer.apple.com/documentation/combine/published

// https://developer.apple.com/documentation/swift/set
// https://developer.apple.com/documentation/swift/result
// https://developer.apple.com/documentation/swiftui/withanimation(_:_:)
// https://docs.swift.org/swift-book/documentation/the-swift-programming-language/typecasting/

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
    
    @Published var scannedProduct: Product?
    
    @Published var produce: Product?

    
    @Published var isLookingUpBarcode = false
    @Published var barcodeErrorMessage: String?
    // allows the user can still continue to a blank form.
    @Published var canAddManually = false

    // VisionKit keeps firing didAdd for the same barcode, so only look each one up once.
    private var lastLookedUpBarcode: String?
    
    @Published var lastOutcomeMessage: String?
    // this stops multiple requests being processed
    @Published var markingProductIds: Set<String> = []

    @Published var productTypes: [ProductType] = []
    private var productTypesVersion: Int?
    private var productTypeMatcher = ProductTypeMatcher(types: [])
    private var productTypeParents: [String: [String]] = [:]

    //Lets previews (& future unit tests) pass a mock service with sample data + defaults to the .shared version for the app
    // https://www.swiftbysundell.com/articles/mocking-in-swift/
    private let service: ProductServiceProtocol
    private let productTypeService = ProductTypeService.shared

    init(service: ProductServiceProtocol = ProductService.shared) {
        self.service = service
    }


    // compactMap allows for nil items to be in the list
    // https://developer.apple.com/documentation/swift/sequence/compactmap(_:)
    private var ownedProductIds: Set<String> {
        Set(products.compactMap { $0.id })
    }

    private var ownedProductNames: Set<String> {
        Set(products.map { normalizedName($0.name) })
    }

    // Each owned type plus every type above it, so owning "chicken-breast" also covers "chicken-meat" and "chicken"
    // Parents only list one level up, so this walks the chain with a stack like a depth first search
    // https://www.kodeco.com/661-swift-algorithm-club-swift-depth-first-search
    private var ownedProductTypes: Set<String> {
        var owned: Set<String> = []
        var toVisit = products.compactMap { $0.productType }

        while !toVisit.isEmpty {
            let key = toVisit.removeLast()
            if owned.contains(key) { continue }
            owned.insert(key)
            toVisit.append(contentsOf: productTypeParents[key] ?? [])
        }
        return owned
    }

    func loadProducts(for user: User){

        service.getProducts(user: user) {result in
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
    
    // Shows the saved list straight away, then asks the backend if there's a newer version
    // Article example is in javascript but i've applied the same thought process.
    // https://web.dev/articles/offline-cookbook#cache-then-network
    func loadProductTypes(for user: User) {
        if productTypes.isEmpty, let saved = productTypeService.loadSavedList() {
            setProductTypes(saved.types ?? [])
            productTypesVersion = saved.version
        }
        productTypeService.fetchProductTypes(user: user, version: productTypesVersion) { result in
            switch result {
            case .success(let list):
                // upToDate comes back with no types, so keep what we have
                guard let types = list.types else { return }
                self.setProductTypes(types)
                self.productTypesVersion = list.version
            case .failure(let error):
                // Not shown to the user, the saved list still works
                print(error)
            }
        }
    }

    // Builds the matcher once per list instead of on every keystroke
    func setProductTypes(_ types: [ProductType]) {
        productTypes = types
        productTypeMatcher = ProductTypeMatcher(types: types)

        // Looked up by key for every recipe ingredient so build it once here instead of searching the whole list each time
        productTypeParents = [:]
        for type in types {
            productTypeParents[type.key] = type.parents
        }
    }

    func suggestProductTypes(text: String) -> [ProductType] {
        productTypeMatcher.suggestions(for: text)
    }

    // The view model is app-scoped instead of account levll, so it outlives sign out. Clear it to fix this carryover
    func resetProducts() {
        products = []
        errorMessage = nil
        hasLoadedProducts = false
        markingProductIds = []
        lastOutcomeMessage = nil
        resetBarcodeLookup()
    }

    func addProducts(for user: User, product: Product, onSuccess: (() -> Void)? = nil) {
        
        service.addProduct(user: user, product: product) { result in
            switch result {
            case .success:
                self.errorMessage = nil
                self.loadProducts(for: user)
                onSuccess?()
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
            
        }
    }
    
    func lookUpBarcode(for user: User, barcode: String) {
        guard !isLookingUpBarcode, barcode != lastLookedUpBarcode else { return }
        
        lastLookedUpBarcode = barcode
        isLookingUpBarcode = true
        barcodeErrorMessage = nil
        canAddManually = false
        
        service.getBarcodeDetails(user: user, barcode: barcode) { result in
            self.isLookingUpBarcode = false
            
            switch result {
            case .success(let product):
                self.scannedProduct = product
            case .failure(let error):
                switch error as? BarcodeLookupError {
                case .notFound(let message):
                    self.barcodeErrorMessage = message
                    self.canAddManually = true
                case .unsupported:
                    self.barcodeErrorMessage = "This barcode isn't supported"
                case .unauthorized:
                    self.barcodeErrorMessage = "Please sign in again"
                case .retry(let message):
                    self.barcodeErrorMessage = message
                case .none:
                    self.barcodeErrorMessage = "Barcode service unavailable, try again"
                }
            }
        }
    }

    func retryBarcodeLookup(for user: User) {
        guard let barcode = lastLookedUpBarcode else { return }
        lastLookedUpBarcode = nil          // clear so the guard above lets it through
        lookUpBarcode(for: user, barcode: barcode)
    }

  
    // data from the camera sheet closing and can be handed to AddProductView
    func resetScanSession() {
        isLookingUpBarcode = false
        barcodeErrorMessage = nil
        canAddManually = false
        lastLookedUpBarcode = nil
    }

    // used when the Add Product sheet closes, and on sign out
    func resetBarcodeLookup() {
        resetScanSession()
        scannedProduct = nil
    }
    
    func deleteProduct(for user: User, product: Product) {
        service.deleteProduct(user: user, product: product) { result in
            switch result {
            case .success:
                self.products.removeAll { $0.id == product.id }
                self.errorMessage = nil
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func editProduct(for user: User, product: Product) {
        service.editProduct(user: user, product: product) { result in
            switch result {
            case .success:
                if let index = self.products.firstIndex(where: { $0.id == product.id }) {
                    self.products[index] = product
                }
                self.errorMessage = nil
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func markOutcome(for user: User, product: Product, outcome: ProductOutcome, wasteReason: WasteReason? = nil) {
        guard let id = product.id, !markingProductIds.contains(id) else { return }
        markingProductIds.insert(id)

        service.markProductOutcome(user: user, product: product, outcome: outcome, wasteReason: wasteReason) { result in
            self.markingProductIds.remove(id)

            switch result {
            case .success:
                withAnimation { self.products.removeAll { $0.id == id } }
                if let wasteReason {
                    self.lastOutcomeMessage = "Marked as wasted · \(wasteReason.displayName)"
                } else {
                    self.lastOutcomeMessage = "Marked as \(outcome.rawValue)"
                }
                self.errorMessage = nil
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.lastOutcomeMessage = error.localizedDescription

                switch error as? ProductOutcomeError {
                case .alreadyMarked:
                    withAnimation { self.products.removeAll { $0.id == id } }
                case .notFound:
                    self.loadProducts(for: user)
                default:
                    break
                }
            }
        }
    }

    // A recipe stores the productId it was generated from, but that is just a snapshot and not updating based on live product availability
    func availability(for ingredient: Ingredient) -> IngredientAvailability {
        guard hasLoadedProducts else { return .unknown }

        // Type first so "PC Free-Run Large Eggs" counts for an "egg" ingredient, then the old id/name check
        if let productType = ingredient.productType, ownedProductTypes.contains(productType) {
            return .owned
        }

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
