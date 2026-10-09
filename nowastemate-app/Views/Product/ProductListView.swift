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
    
    @State private var showScannedProduct = false
    @State private var showProduceClassification = false
    @State private var img = UIImage()
    @State private var showCamera = false
    @State private var prepPicture = false
    @State private var classifications: [String]? = nil
    @State private var showProduceAlert = false
    
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
    private var groupedProducts: [ProductCategory: [Product]] {
        Dictionary(grouping: productVM.products, by: { $0.category ?? .other })
    }
    
    // array for storing total number of categories
    private var sortedCategories: [ProductCategory] {
        ProductCategory.allCases.filter { groupedProducts[$0] != nil }
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
    
                    // reference: https://developer.apple.com/documentation/swiftui/list
                    List {
                        ForEach(sortedCategories, id: \.self) { category in
                            if let items = groupedProducts[category] {
                                Section {
                                    ForEach(items) { product in
                                        ProductRowView(product: product)
                                    }
                                } header: {
                                    Text(category.rawValue.capitalized)
                                        .foregroundStyle(.white.opacity(0.9))
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, -20)
                    .contentMargins(.bottom, 100, for: .scrollContent)
                    .environmentObject(productVM)
                    .onAppear() {
                        print("Loading product data...")
                        guard let user = authVM.user else { return }
                        productVM.loadProducts(for: user)
                    }
                }.padding(20)
            }
            // reference: https://www.hackingwithswift.com/quick-start/swiftui/how-to-present-a-new-view-using-sheets
            // https://www.swiftbysundell.com/articles/backgrounds-and-overlays-in-swiftui/
            .overlay(alignment: .bottom) {
                HStack {
                    addButton
                    Spacer()
                    produceButton
                    Spacer()
                    scanButton
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24) 
            }
            // reference: https://developer.apple.com/documentation/swiftui/view/task(id:priority:_:)
            .overlay(alignment: .top) {
                if let message = productVM.lastOutcomeMessage {
                    Text(message)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.regularMaterial, in: Capsule())
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .task(id: message) {
                            try? await Task.sleep(for: .seconds(2))
                            withAnimation { productVM.lastOutcomeMessage = nil }
                        }
                }
            }.animation(.easeInOut, value: productVM.lastOutcomeMessage)
            
            .sheet(isPresented: $showCamera, onDismiss: {
                if productVM.scannedProduct != nil { showScannedProduct = true }
            }) {
                CameraView(isPresented: $showCamera)
                    .environmentObject(dataScannerVM)
                    .environmentObject(authVM)
                    .environmentObject(productVM)
            }
            .sheet(isPresented: $showScannedProduct, onDismiss: {
                productVM.resetBarcodeLookup()   // full clear
            }) {
                AddProductView(prefill: productVM.scannedProduct)
                    .environmentObject(authVM)
                    .environmentObject(productVM)
            }
            //https://www.hackingwithswift.com/quick-start/swiftui/how-to-present-a-full-screen-modal-view-using-fullscreencover
            .fullScreenCover(isPresented: $prepPicture, onDismiss: {
                
                //get the classification
                guard let classifiedProduce: [String]? = dataScannerVM.getClassification(img: img)
                else {
                    return
                }
                
                classifications = classifiedProduce!
                
                showProduceAlert = true

                
            }) {
                PhotoCaptureView(selectedImage: $img)
            }
            
            .sheet(isPresented: $showProduceClassification) {
                AddProductView(prefill: productVM.produce)
            }
            
            //https://www.avanderlee.com/swiftui/swiftui-alert-presenting/
            //trigger an alert once the classification is done, to allow user to confirm it is correct
            .alert("Produce Detected!", isPresented: $showProduceAlert, actions: {
                
                //present user with the top3 classifications, then have user select the correct one.
                //this can later be used to track when we do not get it right
                
                //placeholder for the classification, as alert loads before we populate the data.
                Button("\(classifications?[0].capitalized ?? "Placeholder")") {
                    productVM.produce = Product(name: classifications![0].capitalized, quantity: 1, createdAt: "", category: ProductCategory.produce)
                    showProduceClassification = true
                    
                }
                .keyboardShortcut(.defaultAction)
                
                Button("Alternative - \(classifications?[1].capitalized ?? "Placerholder")") {
                    productVM.produce = Product(name: classifications![1].capitalized, quantity: 1, createdAt: "", category: ProductCategory.produce)
                    showProduceClassification = true

                }
                
                Button("Alternative - \(classifications?[2].capitalized ?? "Placerholder")") {
                    productVM.produce = Product(name: classifications![2].capitalized, quantity: 1, createdAt: "", category: ProductCategory.produce)
                    showProduceClassification = true

                }
                //https://stackoverflow.com/questions/73616346/swiftui-how-to-hide-cancel-button-in-alert-window
                //hiding the cancel button by not using the roles
                Button("None of the above", role: .destructive) {
                    productVM.produce = nil
                    showProduceClassification = true
                    
                }
                
                //destructive above auto adds the cancel button below
                
            }, message: {
                Text("Below is the produce detected, as well as alternatives")
            })
            
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
    
    private var produceButton: some View {
        Button {
            prepPicture = true
        } label: {
            VStack(spacing: 4) {
                Image(systemName: "carrot")
                    .font(.system(size: 20, weight: .semibold))
                Text("Produce")
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

#if DEBUG
#Preview(traits: .appEnvironment) {
    ProductListView()
}
#endif


private struct ProductRowView: View {
    var product: Product
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var productVM: ProductViewModel
    
    @State private var showWasteReasons = false
    
    private var isMarking: Bool {
        guard let id = product.id else { return false }
        return productVM.markingProductIds.contains(id)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(.body.weight(.medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                ExpiryLabel(product: product)
            }
            
            Spacer()
            
            Text("Qty \(product.quantity)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(red: 0.54, green: 0.54, blue: 0.54))
                .padding(.horizontal, 6)
                .padding(.vertical, 1)
                .overlay(Capsule().stroke(Color(red: 0.79, green: 0.79, blue: 0.79), lineWidth: 1))
            
            outcomeButton
        }
        // hidden link: tapping the row opens EditProductView without List's automatic chevron
        .background {
            NavigationLink {
                EditProductView(product: product)
                    .environmentObject(productVM)
                    .environmentObject(authVM)
            } label: {
                EmptyView()
            }
            .opacity(0)
        }
        .confirmationDialog("Why was it wasted?", isPresented: $showWasteReasons, titleVisibility: .visible) {
            ForEach(WasteReason.allCases) { reason in
                Button(reason.displayName) { mark(.wasted, reason: reason) }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("\(product.name) will be removed from your list.")
        }
    }
    
    private var outcomeButton: some View {
        // reference: https://developer.apple.com/documentation/swiftui/menu
        Menu {
            Button("Consumed", systemImage: "fork.knife") { mark(.consumed) }
            Button("Wasted", systemImage: "trash", role: .destructive) { showWasteReasons = true }
        } label: {
            ZStack {
                if isMarking {
                    ProgressView()
                } else {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color(red: 0.44, green: 0.56, blue: 0.77))
                }
            }
            .frame(width: 36, height: 36)
            .contentShape(Rectangle())
        }
        .disabled(isMarking)
        .accessibilityLabel("Mark \(product.name) as consumed or wasted")
        .buttonStyle(.borderless)
    }
    
    private func mark(_ outcome: ProductOutcome, reason: WasteReason? = nil) {
        guard let user = authVM.user else { return }
        productVM.markOutcome(for: user, product: product, outcome: outcome, wasteReason: reason)
    }
    
}

// reference: https://developer.apple.com/documentation/swiftui/viewbuilder
// coloured line under the product name; fresh products show nothing
private struct ExpiryLabel: View {
    var product: Product
    
    var body: some View {
        switch product.expiryStatus() {
        case .expired:
            label("Expired", color: Color(red: 0.72, green: 0.11, blue: 0.11), weight: .bold)
                .accessibilityLabel("Expired")
        case .today:
            label("Expires Today", color: Color(red: 0.90, green: 0.22, blue: 0.21))
                .accessibilityLabel("Expires today")
        case .tomorrow:
            label("Expires Tomorrow", color: Color(red: 0.91, green: 0.51, blue: 0.23))
                .accessibilityLabel("Expires tomorrow")
        case .soon:
            label("Expires Soon", color: Color(red: 0.79, green: 0.60, blue: 0.02))
            // "Soon" hides the real count, so VoiceOver reads it out
                .accessibilityLabel("Expires in \(product.daysUntilExpiry() ?? 0) days")
        case .fresh:
            EmptyView()
        }
    }
    
    private func label(_ text: String, color: Color, weight: Font.Weight = .medium) -> some View {
        Text(text)
            .font(.caption2.weight(weight))
            .foregroundColor(color)
    }
}
        
        
    

