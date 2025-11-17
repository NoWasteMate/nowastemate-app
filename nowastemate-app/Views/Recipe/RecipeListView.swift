//
//  RecipeListView.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 15/11/25.
//

import SwiftUI

struct RecipeListView: View {
    
    var body: some View {
        ZStack{
            // Gradient Background
            LinearGradient(
                colors: [Color("RecipeListGradientPrimary"), Color("RecipeListGradientSecondary")],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
            
            VStack (alignment: .leading){
                TitleHeader()
                    .padding()
                
                GlassCardCarousel()
                Spacer()
            
            }
        }
    }
}

struct TitleHeader: View {
    var body: some View {
        HStack{
            Text("My Cookbook")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            Spacer()
        }
    }
}

struct GlassCardCarousel: View{
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
           HStack(spacing: 16) {
               GlassCard(cardTitle: "Recipe 1")
                   .frame(width: 250,
                          height: 175)
                   .padding(.leading)
               
               GlassCard(cardTitle: "Recipe 2")
                   .frame(width: 175,
                          height: 175)
               GlassCard(cardTitle: "Recipe 3")
                   .frame(width: 175,
                          height: 175)
           }
           .padding(.vertical) // gives a bit of allowence  on each vertical side of the element to still scroll
       }
    }
}

struct GlassCard: View {
    let cardTitle: String
    var body: some View{
        VStack{
            Spacer()
            Text(cardTitle)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)


        }
        .frame(maxWidth: .infinity)
        .glassEffect(.clear.tint(Color("CardColor")), in:.rect(cornerRadius: 20))
        //https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views
        //https://medium.com/icommunity/liquid-glass-in-swiftui-uikit-77d480db1d29
    }
}

#Preview {
    RecipeListView()
}


