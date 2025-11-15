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

import SwiftUI

struct GroceryListView: View {
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
                    
                    
                    //Sample Data
                    ScrollView() {
                        ItemCardView(title: "Produce",
                                     items: ["Lettuce", "Tomato", "Red Onion", "Spinach"])
                        ItemCardView(title: "Grains",
                                     items: ["Rice", "Pasta"])
                        ItemCardView(title: "Dessert",
                                     items: ["Banana Bread", "Cookies", "Chocolate Cake"])
                    }
                }.padding(20)
                
            }
        }
    }
}

#Preview {
    GroceryListView()
}

struct ItemCardView: View {
    
    var title: String
    var items: [String]
    
    var body: some View {
        VStack() {
            Text(title)
                .font(.headline)
            
            Divider()
            
            ForEach(items, id: \.self) { item in
                HStack {
                    Text(item)
                        .font(.subheadline)
                }
            }
        }
        .frame(width: 350, height: 150, alignment: .center)
        .background(
            Color.white
                .shadow(radius: 5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}
