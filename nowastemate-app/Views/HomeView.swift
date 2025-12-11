//
//  ContentView.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 7/10/25.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var productVM = ProductViewModel()
    @EnvironmentObject var recipeVM: RecipeViewModel

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello " + (authVM.user?.email ?? "None") )
            Button("Logout"){
                authVM.signOut()
            }
            
            Button("Log Token"){
                Task{
                    await authVM.logToken()
                }
            }
            
            Button("Log All Recipes") {
                recipeVM.loadRecipes()
            }
            
            NavigationLink("ProductListView", destination: ProductListView())
            NavigationLink("FamilyView", destination: FamilyView())
            NavigationLink("RecipeListView", destination: RecipeListView())
        }
        .padding()
        .onAppear {
            authVM.createUser()
        }
    }
}

#Preview {
    HomeView()
}
