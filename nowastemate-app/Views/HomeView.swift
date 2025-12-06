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
                authVM.logToken()
            }
            
            Button("Fetch Products") {
                if let user = authVM.user {
                    Task {
                        await productVM.loadProducts(for: user)
                    }
                }
            }
            
            NavigationLink("ProductListView", destination: ProductListView())
            NavigationLink("FamilyView", destination: FamilyView())
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
