//
//  GroceryListView.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2025-11-12.
//

//References:
//https://stackoverflow.com/questions/64379096/how-to-handle-safe-area-space-in-swiftui-while-ignoring-it

//https://stackoverflow.com/questions/63270870/how-do-i-make-uiview-using-linear-gradient-in-swift
//https://developer.apple.com/documentation/SwiftUI/Divider

//Inspiration for adding and removing in the grocery list
//https://www.youtube.com/watch?v=2jFq5DasLsk

// reference for grouping by category: https://danielsaidi.com/blog/2023/04/01/group-and-sort-swift-collections-like-a-pro

// references for loading data with FireStore database: https://swiftwithmajid.com/2022/06/28/the-power-of-task-view-modifier-in-swiftui/#:~:text=struct%20ContentView%3A%20View%20,private%20var%20store%20%3D%20Store
// https://medium.com/@gitonly543/get-data-from-firestore-using-swiftui-38a8de4039d9

import SwiftUI
import Foundation


struct ProductListView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var productVM = ProductViewModel()
    
     let groceryItems: [Product] = [
        Product(
            id: UUID().uuidString,
            name: "Lettuce",
            quantity: 2,
            createdAt: "2025-11-29T18:45:00Z",
            category: "vegetable"
        ),
        Product(
            id: UUID().uuidString,
            name: "Tomato",
            quantity: 6,
            createdAt: "2025-11-29T18:46:00Z",
            category: "fruit"
        ),
        Product(
            id: UUID().uuidString,
            name: "Red Onion",
            quantity: 3,
            createdAt: "2025-11-29T18:47:00Z",
            category: "vegetable"
        )
        ]
    
    @State private var name: String = ""
    @State private var selectedIndex: Int = 0
    
    // create dictionary - key = category, value = Product
    // switch between groceryItems if you want to modify the UI
//    private var groupedProducts: [String: [Product]] { Dictionary(grouping: groceryItems, by: { $0.category })}
    private var groupedProducts: [String: [Product]] { Dictionary(grouping: productVM.products, by: { $0.category })}
    
    // array for storing total number of categories
    private var sortedCategories: [String] {
        groupedProducts.keys.sorted()
    }
    
    var body: some View {
        NavigationStack{
            //Background Gradient
            ZStack {
                LinearGradient(colors: [
                    Color(red: 0.55, green: 0.80, blue: 0.60),
                    Color(red: 0.99, green: 0.96, blue: 0.90)
                ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                
                Spacer()
                            
                VStack{
                    //Grocery List
                    HStack {
                        Text("Grocery List")
                            .font(.largeTitle).bold()
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    //Filter List
                    HStack(spacing: 8) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text("Filter List")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                    }
                    .foregroundColor(.white.opacity(0.9))
                    
                    HStack {
                        TextField("New item", text: $name)
                            .textFieldStyle(.roundedBorder)
                        
                        Button("Add") {
                            print(groupedProducts)
                            print()
                            print(sortedCategories)
                        }
                    }
                    
                    
    
                    ScrollView() {
                        
                        VStack(spacing: 16) {
                            ForEach(sortedCategories, id: \.self) { category in
                                if let items = groupedProducts[category] {
                                    ProductCardView(
                                        title: category,
                                        items: items
                                    )
                                }
                            }
                        }
                        .task {
                            guard let user = authVM.user else { return }
                            await productVM.loadProducts(for: user)
                        }
                        .padding(.top, 8)
                    }
                }.padding(20)
            }
        }
    }
//    private func addItem() {
//        let userInput = name
//        guard !userInput.isEmpty else { return }
//        groceryItems[selectedIndex].items.append(userInput)
//        name = ""
//    }
//    private func deleteItem(_ item: String) {
//        if let index = groceryItems[selectedIndex].items.firstIndex(of: item) {
//            groceryItems[selectedIndex].items.remove(at: index)
//        }
//    }
}

#Preview {
    ProductListView()
}

struct ProductCardView: View {
    
    var title: String
    var items: [Product]
  
    var body: some View {
        VStack() {
            Text(title)
                .font(.headline)
            
            Divider()
            
            ForEach(items) { product in
                HStack {
                    Text(product.name)
                        .font(.subheadline)
                    Text("Quantity: \(product.quantity)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(width: 350,alignment: .center)
        .padding(10)
        .background(
            Color.white
                .shadow(radius: 5)
        )
        
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}
