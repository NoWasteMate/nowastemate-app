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
    @EnvironmentObject var productVM: ProductViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel

    var body: some View {
        VStack{
            ScrollView{
                VStack{
                    Text("Hello, \(authVM.user?.email ?? "None")!" )
                        .font(.title)
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    VStack (spacing: 16){
                        VStack{
                            Text("Total Products Stats")
                        }
                        .frame(maxWidth: .infinity, minHeight: 264)
                        .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 6))
                     
                        VStack{
                            Text("Expiring Soon")
                        }
                        .frame(maxWidth: .infinity, minHeight: 164)
                        .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 6))
                        VStack{
                            Text("Suggested Recipe")
                        }
                        .frame(maxWidth: .infinity, minHeight: 164)
                        .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 6))
                        
                    }
                    .padding(16)
                }
                .padding(16)
                
            }
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
        }

        
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [.homeViewGradientPrimary, .homeViewGradientSecondary],
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
            )
        .onAppear {
            authVM.createUser()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
