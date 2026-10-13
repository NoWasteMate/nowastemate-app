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
    
    private let expiringSoonLimit = 5
    
    // Closest to expiring first, fresh and undated products left out
    private var expiringProducts: [Product] {
        productVM.products
            .filter { $0.expiryStatus() != .fresh }
            .sorted { ($0.daysUntilExpiry() ?? 0) < ($1.daysUntilExpiry() ?? 0) }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.editUserDarkGradient, .editUserLightGradient]), startPoint: .top, endPoint: .bottom)
            
            VStack{
                ScrollView{
                    VStack{
                        
                        HStack{
                            
                            if (authVM.userInfo?.firstName != nil){
                                Text("Hello, \(authVM.userInfo?.firstName ?? "")!" )
                                    .font(.title)
                                    .foregroundStyle(Color.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Text("Hello!" )
                                    .font(.title)
                                    .foregroundStyle(Color.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            
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
                            
                            expiringSoonCard
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
                
                
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear{
            if authVM.userInfo == nil {
                authVM.findUser()
            }
            // Products only loaded from the Inventory tab before, so Home had nothing to show
            if !productVM.hasLoadedProducts, let user = authVM.user {
                productVM.loadProducts(for: user)
            }
        }
    }
    
    private var expiringSoonCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Expiring Soon")
                    .font(.headline)
                Spacer()
                if !expiringProducts.isEmpty {
                    Text("\(expiringProducts.count)")
                        .font(.subheadline.weight(.semibold))
                }
            }
            
            if !productVM.hasLoadedProducts {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if expiringProducts.isEmpty {
                Text("Nothing expiring in the next few days")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            } else {
                // Same rows as the Inventory list, on the list's cell background so the colours still read
                VStack {
                    ForEach(expiringProducts.prefix(expiringSoonLimit)) { product in
                        ProductRowView(product: product)
                    }
                }
                .padding(12)
                .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 10))
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
#Preview(traits: .appEnvironment) {
    HomeView()
}
#endif
