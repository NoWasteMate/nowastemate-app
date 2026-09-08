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
    @EnvironmentObject var dataScannerVM: CameraViewModel
    @EnvironmentObject var productVM: ProductViewModel
    
    @State private var showCamera = false
    
//     let groceryItems: [Product] = [
//        Product(
//            id: UUID().uuidString,
//            name: "Lettuce",
//            quantity: 2,
//            createdAt: "2025-11-29T18:45:00Z",
//            category: "vegetable"
//        ),
//        Product(
//            id: UUID().uuidString,
//            name: "Tomato",
//            quantity: 6,
//            createdAt: "2025-11-29T18:46:00Z",
//            category: "fruit"
//        ),
//        Product(
//            id: UUID().uuidString,
//            name: "Red Onion",
//            quantity: 3,
//            createdAt: "2025-11-29T18:47:00Z",
//            category: "vegetable"
//        )
//        ]
//    
    @State private var name: String = ""
    @State private var selectedIndex: Int = 0
    
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    
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
                    Color(red: 0.30, green: 0.48, blue: 0.36),
                    Color(red: 0.64, green: 0.82, blue: 0.68)
                ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                
                Spacer()
                
                VStack {
                    
                }.padding(40)
                
               
                            
                VStack{
                    //Grocery List
                    HStack {
                        Text("Grocery List")
                            .font(.largeTitle).bold()
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    
                    //Filtering Section
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Search Products", text: $searchText)
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.3))
                    .clipShape(Capsule())

                    HStack {
                        ForEach(["All", "Quick", "Healthy", "Protein"], id: \.self) { filter in
                            Text(filter)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 14).padding(.vertical, 6)
                                .background(filter == selectedFilter ? Color.white.opacity(0.4) : Color.white.opacity(0.15))
                                .clipShape(Capsule())
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
                        .environmentObject(productVM) 
                        .onAppear() {
                            print("Loading product data...")
                            guard let user = authVM.user else { return }
                            productVM.loadProducts(for: user)
                        }
                        .padding(.top, 8)
                    }
                }.padding(20)
            }
            // reference: https://www.hackingwithswift.com/quick-start/swiftui/how-to-present-a-new-view-using-sheets
            // https://www.swiftbysundell.com/articles/backgrounds-and-overlays-in-swiftui/
            .overlay(alignment: .bottom) {
                HStack {
                    addButton
                    Spacer()
                    scanButton
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24) 
            }
            .sheet(isPresented: $showCamera) {
                CameraView(isPresented: $showCamera)
                    .environmentObject(dataScannerVM)
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

    private var scanButton: some View {
        Button {
            showCamera = true
        } label: {
            VStack(spacing: 4) {
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 20, weight: .semibold))
                Text("Scan")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(width: 72, height: 72)
            .background(Color(red: 0.35, green: 0.60, blue: 0.40))
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
        }
    }
    
    private var addButton: some View {
        NavigationLink {
            AddProductView()
                .environmentObject(authVM)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                Text("Add")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(width: 72, height: 72)
            .background(Color(red: 0.35, green: 0.60, blue: 0.40))
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
        }
    }
    
}

#Preview {
    ProductListView()
        .environmentObject(AuthViewModel())
        .environmentObject(CameraViewModel())
        .environmentObject(ProductViewModel())
}

private struct ProductCardView: View {
    
    var title: String
    var items: [Product]
  
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.capitalized)
                .font(.subheadline.weight(.bold))
                .foregroundColor(.secondary)
            Rectangle().frame(height: 1).foregroundColor(.secondary)
            
            VStack(spacing: 10) {
                ForEach(items) { product in
                    ProductRowView(product: product)
                }
            }
        }
        //.frame(width: 380,alignment: .center)
        .padding(10)
        .background(
            Color.white
                .shadow(radius: 5)
                .opacity(0.45)
        )
        
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}

private struct ProductRowView: View {
    var product: Product
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var productVM: ProductViewModel
    
    var body: some View {
        NavigationLink {
            EditProductView(product: product)
                .environmentObject(productVM)
                .environmentObject(authVM)
        } label: {
            HStack {
                Text(product.name)
                    .font(.body.weight(.medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("Qty \(product.quantity)")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color(red: 0.25, green: 0.45, blue: 0.30))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.90, green: 0.96, blue: 0.90))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
        
        
    

