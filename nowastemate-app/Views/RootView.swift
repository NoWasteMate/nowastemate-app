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
    @EnvironmentObject var productVM: ProductViewModel

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
                .environmentObject(productVM)
             
            }
            .onAppear{
                recipeVM.loadRecipes()
                familyVM.findExistingFamily()
                familyVM.findFamilyMembers()
                familyVM.findFamilyId()
                // Needs to check if user exists because .loadProductTypes has user as non optional
                if let user = authVM.user {
                    productVM.loadProductTypes(for: user)
                }
            }
        } else {
            NavigationStack {
                LogInView()
                    .environmentObject(authVM)
            }
            .onAppear {
                productVM.resetProducts()
            }
        }
    }
}


#if DEBUG
#Preview(traits: .appEnvironment) {
    RootView()
}
#endif
