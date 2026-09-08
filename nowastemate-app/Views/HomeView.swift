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
            Spacer()
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, \(authVM.user?.email ?? "None")!" )
                .font(.title)
            Spacer()

            Button("Logout"){
                authVM.signOut()
            }
            .foregroundStyle(.white)
            .padding()
            .background(Color.buttonBackgroundPrimary)
            .cornerRadius(32)
            
            Button("(ADMIN) Log Active Token"){
                Task{
                    await authVM.logToken()
                }
            }
            .padding()
    
            
            
            
            
            
            
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
