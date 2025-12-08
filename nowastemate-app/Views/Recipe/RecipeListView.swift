//
//  RecipeListView.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 15/11/25.
//

import SwiftUI

struct RecipeListView: View {
    
    @State private var searchText = ""
    @EnvironmentObject var recipeVM: RecipeViewModel
    
    var body: some View {
        ZStack{
            // Gradient Background
            LinearGradient(
                colors: [Color("RecipeListGradientPrimary"), Color("RecipeListGradientSecondary")],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
            ScrollView(){
                VStack(alignment: .leading){
                    TitleHeader(titleText: "My Cookbook")
                        .padding()
                    
                    RecipeSearch(text: $searchText)
                        .padding()
                    
                    SubtitleHeader(subtitleText: "Featured Recipes")
                        .padding(.horizontal, 16)
                    GlassCardCarousel()
                    
                    SubtitleHeader(subtitleText: "Suggested Recipes")
                        .padding(.horizontal, 16)
                    
                    GlassCardList()
                    Spacer()
                }
           
            }
        }
        .onAppear(){
            recipeVM.loadRecipes()
        }
    }
}


struct RecipeSearch: View{
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.9))
                .font(.system(size: 20, weight: .semibold))

            TextField("Search Recipes", text: $text)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(10)
        .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 6))
    }
}

struct GlassCardCarousel: View{
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
           HStack(spacing: 16) {
          
               FavouriteGlassCard(cardTitle: "Favourite Recipe 1")
                   .frame(width: 250,
                          height: 175)
                   .padding(.leading)
               
               FavouriteGlassCard(cardTitle: "Favourite Recipe 2")
                   .frame(width: 175,
                          height: 175)
               FavouriteGlassCard(cardTitle: "Favourite Recipe 3")
                   .frame(width: 175,
                          height: 175)
           }
           .padding(.vertical) // gives a bit of allowence  on each vertical side of the element to still scroll
       }
    }
}

struct GlassCardList: View {
    @EnvironmentObject var recipeVM: RecipeViewModel
    var body: some View {
        HStack(spacing: 16) {
            ForEach(recipeVM.recipes) { recipe in
                ListGlassCard(recipe: recipe)
            }
        }
    }
}

struct ListGlassCard: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4){
            VStack (alignment: .leading){
                Text(recipe.recipeName)
                    .font(.title3).bold()
                    .foregroundStyle(.white)
                Text("Uses \(recipe.ingredientsUsed) items")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                
            }
            .padding()
            VStack(alignment: .leading, spacing: 4){
                Text("Cook Time: \(recipe.cookTime)")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                Text("Servings: \(recipe.servings)")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                Text("Difficulty: \(recipe.difficulty)")
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .glassEffect(.clear.interactive().tint(Color("CardColor")), in:.rect(cornerRadius: 20))
        .padding()
    }
}

struct FavouriteGlassCard: View {
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
        .glassEffect(.clear.interactive().tint(Color("CardColor")), in:.rect(cornerRadius: 20))
        //https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views
        //https://medium.com/icommunity/liquid-glass-in-swiftui-uikit-77d480db1d29
    }
}

#Preview {
    RecipeListView()
}


