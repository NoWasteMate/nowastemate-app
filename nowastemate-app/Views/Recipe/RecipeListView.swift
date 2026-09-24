//
//  RecipeListView.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 15/11/25.
//

import SwiftUI

struct RecipeListView: View {
    
    @State private var searchText = ""
    @State private var showGenerateSheet = false
    @EnvironmentObject var recipeVM: RecipeViewModel
    @EnvironmentObject var productVM: ProductViewModel
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationStack{
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
                        SubtitleHeader(subtitleText: "Favourite Recipes")
                            .padding(.horizontal, 16)
                        GlassCardCarousel()
                        
                        SubtitleHeader(subtitleText: "Suggested Recipes")
                            .padding(.horizontal, 16)
                        
                        GeneratedRecipeList()
                        Spacer()
                    }
                }
                // Keeps the button above the tab bar while the list scrolls
                // https://developer.apple.com/documentation/swiftui/view/safeareainset(edge:alignment:spacing:content:)
                .safeAreaInset(edge: .bottom) {
                    GenerateRecipeButton(isLoading: recipeVM.isLoading) { showGenerateSheet = true }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
            }
        }
        .sheet(isPresented: $showGenerateSheet) {
            GenerateRecipeSheet()
        }
        .onAppear(){
            recipeVM.loadRecipes()
            // Recipes store the productIds they were generated from, so the inventory has to be current

            if let user = authVM.user {
                productVM.loadProducts(for: user)
            }
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

// Plain glass to match the tab bar below it
// https://developer.apple.com/documentation/swiftui/primitivebuttonstyle/glass
struct GenerateRecipeButton: View {
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                } else {
                    Label("Generate Recipe", systemImage: "sparkles")
                        .labelStyle(.iconOnly)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            .frame(width: 28, height: 28) // Same size in both states so the button doesn't resize
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .controlSize(.large)
        .disabled(isLoading)
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

struct GeneratedRecipeList: View {
    @EnvironmentObject var recipeVM: RecipeViewModel
    var body: some View {
        // Using Lazy Stack for better performance. Glass views should be created as they come because the visual is quite taxing on the system
        LazyVStack{
            if(recipeVM.isLoading){
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding(48)
            }
            else{
                ForEach(recipeVM.recipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)){
                        ListGlassCard(recipe: recipe)
                    }
                }
            }
        }
    }
}

struct ListGlassCard: View {
    let recipe: Recipe
    @EnvironmentObject var productVM: ProductViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 12){
            Image(systemName: icon(for: recipe.category))
                .font(.title)
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(.white.opacity(0.15), in: .rect(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 4){
                Text(recipe.recipeName)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                // Falls back to the count the recipe was generated with
                Text("Uses \(productVM.ownedIngredientCount(in: recipe.ingredients) ?? recipe.ingredientsUsed) items")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .italic()
                HStack(spacing: 12){
                    Label("\(recipe.cookTime) min", systemImage: "clock")
                    Label("\(recipe.servings) servings", systemImage: "person.2")
                    Label(recipe.difficulty.capitalized, systemImage: "chart.bar")
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.85))
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.clear.interactive().tint(Color("CardColor")), in:.rect(cornerRadius: 20))
        .padding(.horizontal)
        .padding(.vertical, 4)
        
        .visualEffect { content, proxy in
            let progress = min(max(proxy.frame(in: .global).origin.y / rampDistance, 0), 1)
            return content
                .saturation(topSaturation + (bottomSaturation - topSaturation) * progress)
        }
    }

    // Distance down the screen over which the saturation ramp plays out.
    private let rampDistance: CGFloat = 1000
    private let topSaturation: Double = 0.6
    private let bottomSaturation: Double = 3.0

    private func icon(for category: RecipeCategory?) -> String {
        switch category {
        case .soup: return "cup.and.heat.waves.fill"
        case .salad: return "leaf.fill"
        case .pasta: return "frying.pan.fill"
        case .handheld: return "takeoutbag.and.cup.and.straw.fill"
        case .breakfast: return "sunrise.fill"
        case .dessert: return "birthday.cake.fill"
        case .drink: return "waterbottle.fill"
        case .platedMain: return "fork.knife"
        case .general: return "menucard.fill"
        case nil: return "questionmark.square.dashed"
        }
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

#if DEBUG
#Preview(traits: .appEnvironment) {
    RecipeListView()
}
#endif
