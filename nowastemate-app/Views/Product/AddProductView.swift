//
//  AddProductView.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2025-12-08.
//


//references:
// to show how to use date picker - https://www.youtube.com/watch?v=9UovPNh4Csw

import SwiftUI

struct AddProductView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var productVM: ProductViewModel
    
    @State private var name = ""
    @State private var quantity = 1
    @State private var category = ""
    @State private var isPerishable = true
    
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
                        Text("Name of Product").fontWeight(.bold)
                            .foregroundStyle(.white)
                        TextField("example: Apples", text: $name)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                    }.padding(8)
                    
                    HStack {
                        VStack(spacing: 2) {
                            Button { quantity += 1 } label: { Image(systemName: "chevron.up") }
                            Button { if quantity > 1 { quantity -= 1 } } label: { Image(systemName: "chevron.down") }
                        }
                        Text("\(quantity)")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(12)
                    
                    HStack(spacing: 0) {
                        Text("Perishable")
                            .frame(maxWidth: .infinity).padding()
                            .background(isPerishable ? Color.white : .clear)
                            .onTapGesture { isPerishable = true }
                        Text("Non Perishable")
                            .frame(maxWidth: .infinity).padding()
                            .background(!isPerishable ? Color.white : .clear)
                            .onTapGesture { isPerishable = false }
                    }
                    .background(Color.white.opacity(0.3))
                    .clipShape(Capsule())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category of the product").font(.headline)
                        TextField("example: Fruit", text: $category)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                    }.padding(8)
                    
                    //Button to send the user inputted product to ProductViewModel
//                    Button("Save Product") {
//                        guard let user = authVM.user else { return }
//                        
//                        let userInputtedProduct = Product(name: name, quantity: quantity, createdAt: "", category: category)
//                        
//                        productVM.addProducts(for: user, product: userInputtedProduct)
//                    }
                    //perishable not added in yet
                    Button("Save Product") {
                        guard let user = authVM.user else { return }
                        let userInputtedProduct = Product(name: name, quantity: quantity, createdAt: "", category: category)
                        productVM.addProducts(for: user, product: userInputtedProduct)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .padding(.horizontal)
                }
            }
            
        }
    }
}

#Preview {
    AddProductView()
}
