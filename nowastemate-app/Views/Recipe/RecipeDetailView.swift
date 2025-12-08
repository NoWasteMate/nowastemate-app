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
                        .foregroundStyle(.white)
                    
                    Text(recipe.description)
                        .font(.title3)
                        .foregroundStyle(.white)
                        .padding(.vertical)
                    
                    VStack{
                        // https://www.hackingwithswift.com/forums/swiftui/accessing-the-index-in-foreach/1334
                        // Accessing indicies in for each (there is no id for ingredients)
                        ForEach(recipe.ingredients.indices, id: \.self) { index in
                            Text(recipe.ingredients[index].name)
                        }
                        .foregroundStyle(.white)
                        
                    }
                   
                    
                    VStack{
                        Text("Cook Time: \(recipe.cookTime) Minutes")
                            .foregroundStyle(.white)
                        Text("Prep Time: \(recipe.prepTime) Minutes")
                            .foregroundStyle(.white)
                        Text("\(recipe.servings) Servings")
                            .foregroundStyle(.white)
                        Text("\(recipe.difficulty) Difficulty")
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .glassEffect(.clear.interactive(false), in: .rect(cornerRadius: 6))
                    .padding(.vertical)
                    
                    
                    
                    
                    
                    Spacer()
                    
                }
            }
            .padding()
                
        }
    }
}
