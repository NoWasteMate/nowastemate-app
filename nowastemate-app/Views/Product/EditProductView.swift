//
//  EditProductView.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2026-09-08.
//

import SwiftUI
import FirebaseAuth

// Going to be the same format as the AddProductView
// Need to add a Navigation Link from the AddProductView so that each product can be edited and redirected here
// Reference: https://developer.apple.com/documentation/swiftui/state
// https://medium.com/@eyupcimen/state-is-now-a-macro-in-xcode-27-heres-why-it-matters-b42c219aade6

struct EditProductView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var productVM: ProductViewModel
    @Environment(\.dismiss) var dismiss

    var product: Product

    @State private var name: String
    @State private var quantity: Int
    @State private var category: ProductCategory
    @State private var expiryDate = Date()
    @State private var showDatePicker = false
    
    init(product: Product) {
        self.product = product
        _name = State(initialValue: product.name)
        _quantity = State(initialValue: product.quantity)
        _category = State(initialValue: product.category ?? .other)
        if let dateExpiration = product.dateExpiration,
               let parsedDate = ISO8601DateFormatter().date(from: dateExpiration) {
                _expiryDate = State(initialValue: parsedDate)
        } else {
            _expiryDate = State(initialValue: Date())
        }
    }
    
    // going to take the AddProductView code and see if it works
    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 0.23, green: 0.29, blue: 0.24),
                Color(red: 0.49, green: 0.57, blue: 0.50)
            ], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    Spacer()
                    
                    Text("Edit Item Details Below")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    
                    
                    Text("Name of Product")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("example: Apples", text: $name)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                    }.padding(8)
                    
                    
                    Text("Quantity of Product")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
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
                    
                                        
                    Text("Category of Product")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Picker("Category", selection: $category) {
                        ForEach(ProductCategory.allCases, id: \.self) { category in
                            Text(category.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.white)
                    
                    Text("Expiry Date").fontWeight(.bold)
                        .foregroundStyle(.white)
                    HStack {
                        Button("Pick Date", systemImage: "calendar") {
                            showDatePicker = true
                        }
                        .padding()
                        .background(Color.white)
                        .foregroundStyle(.black)
                        .clipShape(Capsule())
                        Button("Estimate with AI", systemImage: "apple.intelligence") {
                            // no AI implementation yet, just making UI similar to the Figma
                        }
                        .padding()
                        .background(Color.white)
                        .foregroundStyle(.black)
                        .clipShape(Capsule())
                    }
                    .sheet(isPresented: $showDatePicker) {
                        NavigationStack {
                            DatePicker("Expiry Date", selection: $expiryDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .padding()
                                .navigationTitle("Expiry Date")
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    ToolbarItem(placement: .confirmationAction) {
                                        Button("Done") {
                                            showDatePicker = false
                                        }
                                    }
                                }
                        }
                    }
                    Text("Expires: \(expiryDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    
                    //Button to send the user inputted product to ProductViewModel
                    //                    Button("Save Product") {
                    //                        guard let user = authVM.user else { return }
                    //
                    //                        let userInputtedProduct = Product(name: name, quantity: quantity, createdAt: "", category: category)
                    //
                    //                        productVM.addProducts(for: user, product: userInputtedProduct)
                    //                    }
                    
                    Text("Image").fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Button {
                        // no photo coded in yet. Just UI preparation
                    } label: {
                        Label("Add Photo of Product", systemImage: "camera")
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.white)
                    .foregroundStyle(.black)
                    .clipShape(Capsule())
                    .padding(.horizontal)
                    
                    
                    
                    HStack(spacing: 12) {
                        Button("Edit Product") {
                            guard let user = authVM.user else { return }

                            var updatedProduct = product
                            updatedProduct.name = name
                            updatedProduct.quantity = quantity
                            updatedProduct.category = category
                            updatedProduct.dateExpiration = ISO8601DateFormatter().string(from: expiryDate)

                            productVM.editProduct(for: user, product: updatedProduct)
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                        
                        Button("Delete Product") {
                            guard let user = authVM.user else { return }
                            productVM.deleteProduct(for: user, product: product)
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal)
                }
            }
            
        }
    }
}

//#Preview {
//    EditProductView()
//}
