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
    @State private var expiryDate = Date()
    @State private var showDatePicker = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 0.30, green: 0.48, blue: 0.36),
                Color(red: 0.64, green: 0.82, blue: 0.68)
            ], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    
                    Spacer()
                    
                    Text("Enter Item Details Below")
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
                    
                    
                    Text("Type of Product")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
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
                    
                    //Category might be depracated later.
                    Text("Category of Product")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("example: Fruit", text: $category)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                    }.padding(8)
                    
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
                        DatePicker("Expiry Date", selection: $expiryDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .padding()
                    }
                    
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
                    
                    
                    
                    //perishable not added in yet
                    Button("Save Product") {
                        guard let user = authVM.user else { return }
                        let userInputtedProduct = Product(
                            name: name,
                            quantity: quantity,
                            createdAt: "",
                            dateExpiration: ISO8601DateFormatter().string(from: expiryDate),
                            category: category
                        )
                        
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
