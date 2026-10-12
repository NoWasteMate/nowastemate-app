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
    @EnvironmentObject var analyticsVM: AnalyticsViewModel

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
                .environmentObject(analyticsVM)
             
            }
            .onAppear{
                if let user = authVM.user {
                    recipeVM.loadRecipes(for: user)
                    familyVM.findExistingFamily(for: user)
                    familyVM.findFamilyMembers(for: user)
                    familyVM.findFamilyId(for: user)
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
                analyticsVM.resetAnalytics()
            }
        }
    }
}


#if DEBUG
#Preview(traits: .appEnvironment) {
    RootView()
}
#endif
