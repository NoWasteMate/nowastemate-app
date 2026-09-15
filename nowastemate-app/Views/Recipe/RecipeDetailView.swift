//
//  RecipeDetailView.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 15/11/25.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @EnvironmentObject var productVM: ProductViewModel

    var body: some View {
    
        ZStack {
            LinearGradient(
                colors: [Color("RecipeListGradientPrimary"), Color("RecipeListGradientSecondary")],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
            ScrollView(){
                VStack(alignment:.leading){
                    Text(recipe.recipeName)
                        .font(.largeTitle)
                    
                    Text(recipe.description)
                        .font(.title3)
                        .padding(.vertical)
                    
                    VStack (alignment: .leading){
                        // https://www.hackingwithswift.com/forums/swiftui/accessing-the-index-in-foreach/1334
                        // Accessing indicies in for each (there is no id for ingredients)
                        Text("Ingredients:")
                            .font(.title2)
                            .padding(.vertical)
                        ForEach(recipe.ingredients.indices, id: \.self) { index in
                            let ingredient = recipe.ingredients[index]
                            let availability = productVM.availability(for: ingredient)
                            HStack(spacing: 8) {
                                Image(systemName: icon(for: availability))
                                    .foregroundStyle(iconColour(for: availability))
                                    .accessibilityLabel(accessibilityLabel(for: availability))
                                Text(ingredient.name)
                            }
                        
                            
                        }
                        
                    }
                   
                    
                    VStack{
                        Text("Cook Time: \(recipe.cookTime) Minutes")
                        Text("Prep Time: \(recipe.prepTime) Minutes")
                        Text("\(recipe.servings) Servings")
                        Text("\(recipe.difficulty) Difficulty")
                    }
                    .frame(maxWidth: .infinity)
                    .glassEffect(.clear.interactive(false), in: .rect(cornerRadius: 6))
                    .padding(.vertical)
                    
                    VStack (alignment: .leading){
                        
                        Text("Instructions:")
                            .font(.title2)
                            .padding(.vertical)
                        ForEach(recipe.instructions.indices, id: \.self) { index in
                            HStack(alignment: .top, spacing: 12){
                                Text("\(index + 1).")
                                Text("\(recipe.instructions[index].description)")
                            }
                            .padding(.vertical, 4)   
                        }
                    }
                }.foregroundStyle(.white)
            }
            .padding()
                
        }
    }

    private func icon(for availability: IngredientAvailability) -> String {
        switch availability {
        case .owned: return "checkmark.circle.fill"
        case .missing: return "xmark.circle"
        case .unknown: return "circle.dotted"
        }
    }

    private func iconColour(for availability: IngredientAvailability) -> Color {
        switch availability {
        case .owned: return .green
        case .missing: return .white.opacity(0.6)
        case .unknown: return .white.opacity(0.35)
        }
    }

    // The icon is the only thing carrying availability, so VoiceOver needs it named.
    // https://developer.apple.com/documentation/swiftui/view/accessibilitylabel(_:)-1d7jv
    private func accessibilityLabel(for availability: IngredientAvailability) -> String {
        switch availability {
        case .owned: return "In your inventory"
        case .missing: return "Not in your inventory"
        case .unknown: return "Checking your inventory"
        }
    }
}
