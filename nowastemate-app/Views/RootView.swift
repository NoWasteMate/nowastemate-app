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

    var body: some View {
        
        
        
        if authVM.isSignedIn {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                ProductListView()
                    .tabItem {
                        Label("Products", systemImage: "cart.fill")
                    }
            }
                .environmentObject(authVM)
            NavigationStack {
                HomeView()
                    .environmentObject(authVM)
                    .environmentObject(familyVM)
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
    
}
