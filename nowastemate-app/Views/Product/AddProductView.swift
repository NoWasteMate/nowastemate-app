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
    
    // nil for the manual Add button, set by a barcode scan OR photo classification to fill in the form
    var prefill: Product? = nil
    
    // https://www.hackingwithswift.com/books/ios-swiftui/validating-and-disabling-forms
    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    @State private var name = ""
    @State private var quantity = 1
    @State private var category: ProductCategory = .other
    @State private var expiryDate = Calendar.current.date(byAdding: .day, value: 7, to:Date()) ?? Date()
    @State private var showDatePicker = false
    
    // onAppear fires again when navigating back this stops it wiping the user's edits
    @State private var hasAppliedPrefill = false

    // Suggestions only show while typing and dissapear once they are picked
    // https://www.hackingwithswift.com/quick-start/swiftui/how-to-dismiss-the-keyboard-for-a-textfield
    @FocusState private var nameIsFocused: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color("ProductListGradientPrimary"),
                Color("ProductListGradientSecondary")
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
                            .focused($nameIsFocused)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)

                        ZStack {
                            // Invisible pill that keeps one row of space, so the fields below don't jump
                            // A real pill instead of a fixed height, so it still matches with larger text sizes
                            // https://developer.apple.com/documentation/swiftui/view/hidden()
                            Button("Suggestion") {}
                                .buttonStyle(.glass)
                                .hidden()

                            if nameIsFocused {
                                nameSuggestions
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }.padding(8)
                    
                    
                    Text("Quantity of Product")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    HStack(spacing: 20) {
                        Button { quantity -= 1 } label: {
                            Image(systemName: "minus")
                                .frame(width: 44, height: 44)
                        }
                        .disabled(quantity <= 1)
                        .opacity(quantity <= 1 ? 0.3 : 1)
                        .accessibilityLabel("Decrease quantity")

                        Text("\(quantity)")
                            .font(.title2.bold())
                            .monospacedDigit()
                            .frame(minWidth: 40)
                            .contentTransition(.numericText())

                        Button { quantity += 1 } label: {
                            Image(systemName: "plus")
                                .frame(width: 44, height: 44)
                        }
                        .accessibilityLabel("Increase quantity")
                    }
                    .font(.title3.weight(.semibold))
                    .padding(.horizontal, 8)
                    .background(.regularMaterial)
                    .foregroundStyle(.primary)
                    .clipShape(Capsule())
                    .animation(.snappy, value: quantity)
            
                    // Hidden for now because the backend sets the category from the Product Type on add, it can still be changed on edit
//                    Text("Category of Product")
//                        .fontWeight(.bold)
//                        .foregroundStyle(.white)
//                    Picker("Category", selection: $category) {
//                        ForEach(ProductCategory.allCases, id: \.self) { category in
//                            Text(category.rawValue.capitalized)
//                        }
//                    }
//                    .pickerStyle(.menu)
//                    .tint(.white)
                    
                    Text("Expiry Date").fontWeight(.bold)
                        .foregroundStyle(.white)
                        Button("Pick Date", systemImage: "calendar") {
                            showDatePicker = true
                        }
                            .padding()
                            .background(.regularMaterial)
                            .foregroundStyle(.primary)
                            .clipShape(Capsule())
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
                    
//                    Text("Image").fontWeight(.bold)
//                        .foregroundStyle(.white)
//
//                    Button {
//                        // no photo coded in yet. Just UI preparation
//                    } label: {
//                        Label("Add Photo of Product", systemImage: "camera")
//                            .frame(maxWidth: .infinity)
//                    }
//                    .padding()
//                    .background(Color.white)
//                    .foregroundStyle(.black)
//                    .clipShape(Capsule())
//                    .padding(.horizontal)
//                    
                    
                    Button("Save Product") {
                        guard let user = authVM.user, isFormValid else { return }

                        // Barcode tags only describe the scanned name so a renamed product should be matched by its new name instead
                        var categoryTags: [String]? = nil
                        if name == prefill?.name {
                            categoryTags = prefill?.categoryTags
                        }

                        let userInputtedProduct = Product(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            quantity: quantity,
                            createdAt: "",
                            dateExpiration: ISO8601DateFormatter().string(from: expiryDate),
                            category: category,
                            categoryTags: categoryTags
                        )
                        
                        productVM.addProducts(for: user, product: userInputtedProduct) {
                            dismiss()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .padding(.horizontal)
                    .disabled(!isFormValid)
                    .opacity(isFormValid ? 1 : 0.3)
                }
            }
            
        }
        .onAppear {
            guard let prefill, !hasAppliedPrefill else { return }
            hasAppliedPrefill = true
            name = prefill.name
            quantity = max(prefill.quantity, 1)
            category = prefill.category ?? .other
        }
    }

    // starts with 3 pills, then 2, then 1, so a long name drops a suggestion instead of being cut off with "..." or text wrapping
    // https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-an-adaptive-layout-with-viewthatfits
    private var nameSuggestions: some View {
        let suggestions = productVM.suggestProductTypes(text: name)

        return ViewThatFits {
            SuggestionRow(types: Array(suggestions.prefix(3)), onPick: pick)
            SuggestionRow(types: Array(suggestions.prefix(2)), onPick: pick)
            SuggestionRow(types: Array(suggestions.prefix(1)), onPick: pick)
        }
    }

    private func pick(_ type: ProductType) {
        name = type.name.capitalized
        nameIsFocused = false
    }
}

private struct SuggestionRow: View {
    var types: [ProductType]
    // https://swiftwithmajid.com/2019/11/06/the-power-of-closures-in-swiftui/
    var onPick: (ProductType) -> Void

    var body: some View {
        HStack {
            ForEach(types) { type in
                Button(type.name.capitalized) {
                    onPick(type)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.capsule)
            }
        }
    }
}

#if DEBUG
#Preview(traits: .appEnvironment) {
    AddProductView()
}
#endif
