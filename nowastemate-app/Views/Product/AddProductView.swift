//
//  AddProductView.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2025-12-08.
//

import SwiftUI

struct AddProductView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var productVM: ProductViewModel
    
    @State private var name = ""
    @State private var quantity = 1
    @State private var category = ""
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 0.55, green: 0.80, blue: 0.60),
                Color(red: 0.99, green: 0.96, blue: 0.90)
            ], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    
                    Spacer()
                    
                    Text("Enter Item Details Below")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name of the Product").font(.headline)
                        TextField("example: Apples", text: $name)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                    }.padding(8)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quantity").font(.headline).foregroundStyle(.white)
                        Stepper(value: $quantity, in: 1...50) {
                            Text("\(quantity)")
                                .foregroundStyle(.white)
                        }
                    }.padding(8)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category of the product").font(.headline)
                        TextField("example: Fruit", text: $category)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                    }.padding(8)
                    
                    //Button to send the user inputted product to ProductViewModel
                    Button("Save Product") {
                        guard let user = authVM.user else { return }
                        
                        let userInputtedProduct = Product(name: name, quantity: quantity, createdAt: "", category: category)
                        
                        productVM.addProducts(for: user, product: userInputtedProduct)
                    }
                    
                }
            }
            
        }
    }
}

#Preview {
    AddProductView()
}
