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

import SwiftUI
import Foundation

//concept of adding (will be organized later)
struct GroceryItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var items: [String]
}

struct GroceryListView: View {
    
    @State private var groceryItems: [GroceryItem] = [
            GroceryItem(title: "Produce", items: ["Lettuce", "Tomato", "Red Onion", "Spinach"]),
            GroceryItem(title: "Grains", items: ["Rice", "Pasta"]),
            GroceryItem(title: "Dessert", items: ["Banana Bread", "Cookies", "Chocolate Cake"])
        ]
    
    @State private var name: String = ""
    @State private var selectedIndex: Int = 0
    
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
                            addItem()
                        }
                    }
                    
                    
                    //Sample Data
                    ScrollView() {
                        
                        Picker("Category", selection: $selectedIndex) {
                            ForEach(0..<groceryItems.count, id: \.self) { index in
                                Text(groceryItems[index].title)
                                    .tag(index)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        
                        ItemCardView(
                            title: groceryItems[selectedIndex].title,
                            items: groceryItems[selectedIndex].items,
                            onDelete: { item in
                                deleteItem(item)
                            }
                            
                        )
                    }
                }.padding(20)
            }
        }
    }
    private func addItem() {
        let userInput = name
        guard !userInput.isEmpty else { return }
        groceryItems[selectedIndex].items.append(userInput)
        name = ""
    }
    private func deleteItem(_ item: String) {
        if let index = groceryItems[selectedIndex].items.firstIndex(of: item) {
            groceryItems[selectedIndex].items.remove(at: index)
        }
    }
}

#Preview {
    GroceryListView()
}

struct ItemCardView: View {
    
    var title: String
    var items: [String]
    var onDelete: (String) -> Void
    
    var body: some View {
        VStack() {
            Text(title)
                .font(.headline)
            
            Divider()
            
            ForEach(items, id: \.self) { item in
                HStack {
                    Text(item)
                        .font(.subheadline)
                    Button {
                        onDelete(item)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .foregroundColor(.red)
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
