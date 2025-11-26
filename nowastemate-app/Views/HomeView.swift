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

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello " + (authVM.user?.email ?? "None") )
            Button("Logout"){
                authVM.signOut()
            }
            
            Button("Auth ID"){
                AuthService.shared.getUserEmail(user: authVM.user!)
            }
            Button("Log Token"){
                AuthService.shared.logAuthID(user: authVM.user!)
            }
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
