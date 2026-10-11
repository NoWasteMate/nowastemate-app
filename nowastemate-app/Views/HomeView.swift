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
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.editUserDarkGradient, .editUserLightGradient]), startPoint: .top, endPoint: .bottom)
            
            VStack{
                ScrollView{
                    VStack{
                        
                        HStack{
                            
                            Text("Hello, \(authVM.user?.email ?? "None")!" )
                                .font(.title)
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            
                            NavigationLink {
                                EditUserView()
                            }
                            label: {
                                Image(systemName: "person")
                                    .foregroundColor(.white)
                                    .imageScale(.small)
                                    .padding()
                                    .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 30))
                                    
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .topTrailing)
                        .padding(.top, 40)
                        
                        
                        
                        VStack (spacing: 16){
                            VStack{
                                Text("Total Products Stats")
                            }
                            .frame(maxWidth: .infinity, minHeight: 264)
                            .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 6))
                            
                            NavigationLink {
                                WasteTrendView()
                            } label: {
                                VStack{
                                    Text("Waste Trends")
                                        .foregroundStyle(.white)
                                }
                                .frame(maxWidth: .infinity, minHeight: 164)
                                .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 6))
                            }
                            
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
                
                Button("(ADMIN) Log Active Token"){
                    Task{
                        await authVM.logToken()
                    }
                }
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#if DEBUG
#Preview(traits: .appEnvironment) {
    HomeView()
}
#endif
