//
//  RootView.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 25/11/25.
//

import SwiftUI

// One case per tab so the TabView selection can be set via code
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-embed-views-in-a-tab-bar-using-tabview
enum RootTab {
    case home
    case inventory
    case recipes
    case families
}

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var familyVM: FamilyViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel
    @EnvironmentObject var productVM: ProductViewModel
    @EnvironmentObject var analyticsVM: AnalyticsViewModel
    @Environment(\.scenePhase) var scenePhase

    @State private var selectedTab: RootTab = .home
    
    
    var body: some View {
        
        
        
        if authVM.isSignedIn {
           
            NavigationStack {
                TabView(selection: $selectedTab) {
                    Tab("Home", systemImage: "house", value: .home) {
                        HomeView(selectedTab: $selectedTab)
                    }

                    Tab("Inventory", systemImage: "checklist", value: .inventory) {
                        ProductListView()
                    }

                    Tab("Recipes", systemImage: "book.pages.fill", value: .recipes) {
                        RecipeListView()
                    }
        
                    
                    Tab("Families", systemImage: "person.3.fill", value: .families) {
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
            // Found that expiry labels only work out the days left when a view redraws, so the ios app left in the background overnight kept showing yesterday's labels
            // Reloading also reschedules notifications and picks up the family members edits
            // https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-when-your-app-moves-to-the-background-or-foreground-with-scenephase
            // The article's single parameter onChange is deprecated. Xcode suggested adding the old value as a first parameter
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    if let user = authVM.user {
                        if productVM.hasLoadedProducts {
                            productVM.loadProducts(for: user)
                        }
                        if productVM.hasLoadedFamilyProducts {
                            productVM.loadFamilyProducts(for: user)
                        }
                    }
                }
            }
        } else {
            NavigationStack {
                LogInView()
                    .environmentObject(authVM)
            }
            .onAppear {
                productVM.resetProducts()
                recipeVM.resetRecipes()
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
