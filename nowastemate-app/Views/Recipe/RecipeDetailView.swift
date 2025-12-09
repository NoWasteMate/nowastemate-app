//
//  RecipeDetailView.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 15/11/25.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
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
                            Text(recipe.ingredients[index].name)
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
}
