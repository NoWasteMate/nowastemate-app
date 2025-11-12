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
            
            Text("Grocery List")
                .font(.largeTitle).bold()
            
            Spacer()
            
            VStack {
                //SAMPLES
                ItemCardView()
                ItemCardView()
                ItemCardView()
            }
            
            Spacer()
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
