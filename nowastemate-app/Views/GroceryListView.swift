//
//  GroceryListView.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2025-11-12.
//

import SwiftUI

struct GroceryListView: View {
    var body: some View {
        
        NavigationStack{
            ZStack {
                LinearGradient(colors: [
                    Color(red: 0.55, green: 0.80, blue: 0.60),
                    Color(red: 0.99, green: 0.96, blue: 0.90)
                ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                
                Spacer()
            
                VStack{
                    HStack {
                        Text("Grocery List")
                            .font(.largeTitle).bold()
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    
                    //SAMPLES
                    ScrollView() {
                        ItemCardView()
                        ItemCardView()
                        ItemCardView()
                    }
                }
            }
        }
    }
}

#Preview {
    GroceryListView()
}

struct ItemCardView: View {
    
    var body: some View {
        VStack {
            Text("ITEM SAMPLE")
            Text("Description: This is an item")
        }
        .frame(width: 350, height: 100, alignment: .center)
        .background(
            Color.gray
                .blur(radius: 100)
                .shadow(radius: 5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}
