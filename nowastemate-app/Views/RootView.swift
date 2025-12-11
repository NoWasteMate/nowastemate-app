//
//  RootView.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 25/11/25.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var familyVM: FamilyViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel

    var body: some View {
        
        
        
        if authVM.isSignedIn {
           
            NavigationStack {
                TabView {
                    Tab("Home", systemImage: "house") {
                        HomeView()
                    }

                    Tab("Inventory", systemImage: "checklist") {
                        ProductListView()
                    }

                    Tab("Recipes", systemImage: "book.pages.fill") {
                        RecipeListView()
                    }
        
                    
                    Tab("Families", systemImage: "person.3.fill") {
                        FamilyView()
                        
                    }
                }
                .environmentObject(authVM)
                .environmentObject(familyVM)
                .environmentObject(recipeVM)
             
            }
            .onAppear{
                recipeVM.loadRecipes()
            }
        } else {
            NavigationStack {
                LogInView()
                    .environmentObject(authVM)
            }
        }
    }
}


#Preview {
    RootView()
        .environmentObject(AuthViewModel())
        .environmentObject(FamilyViewModel())
        .environmentObject(RecipeViewModel())
    
}
