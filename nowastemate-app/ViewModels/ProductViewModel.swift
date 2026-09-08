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

}
