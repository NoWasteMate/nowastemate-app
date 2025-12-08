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
                HomeView()
                    .environmentObject(authVM)
                    .environmentObject(familyVM)
                    .environmentObject(recipeVM)
            }
        } else {
            LogInView()
                .environmentObject(authVM)
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AuthViewModel())
        .environmentObject(FamilyViewModel())
        .environmentObject(RecipeViewModel())
    
}
