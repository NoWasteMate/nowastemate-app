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
    
    @Binding var selectedTab: RootTab
    
    private let expiringSoonLimit = 5
    private let totalCircleSize: CGFloat = 224
    
    // Closest to expiring first, fresh and undated products left out
    private var expiringProducts: [Product] {
        productVM.products
            .filter { $0.expiryStatus() != .fresh }
            .sorted { ($0.daysUntilExpiry() ?? 0) < ($1.daysUntilExpiry() ?? 0) }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.editUserDarkGradient, .editUserLightGradient]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                HStack {
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
                
                List {
                    Section {
                        // onTapGesture instead of Button so only the circle is tappable, not the whole List row
                        // https://stackoverflow.com/questions/56561064/swiftui-multiple-buttons-in-a-list-row/
                        totalProductsCircle
                            .onTapGesture {
                                selectedTab = .inventory
                            }
                        .frame(maxWidth: .infinity, minHeight: 264)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                    }
                
                    Section {
                        VStack {
                            Text("Waste Trends")
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity, minHeight: 164)
                        .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 6))
                        // hidden link like ProductRowView so the card doesn't get List's chevron
                        .background {
                            NavigationLink {
                                WasteTrendView()
                            } label: {
                                EmptyView()
                            }
                            .opacity(0)
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                    }
                
                    expiringSoonSection
                
                    Section {
                        VStack {
                            Text("Suggested Recipe")
                        }
                        .frame(maxWidth: .infinity, minHeight: 164)
                        .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 6))
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
               
                .listRowSpacing(12)
                .padding(.horizontal, -20)
            }
            .padding([.horizontal, .top], 26)
        }
        .onAppear{
            if authVM.userInfo == nil {
                authVM.findUser()
            }
            // Only Inventory and Recipes loaded products before, so load here since neither have been opened yet
            if !productVM.hasLoadedProducts, let user = authVM.user {
                productVM.loadProducts(for: user)
            }
            
            NotificationService.shared.requestAuth()
        }
    }
    
    private var totalProductsCircle: some View {
        VStack {
            Text("\(productVM.products.count)")
                .font(.system(size: 64, weight: .bold))
            Text("Products at Home")
                .font(.subheadline)
        }
        .foregroundStyle(.white)
        .frame(width: totalCircleSize, height: totalCircleSize)
        .background(
            LinearGradient(colors: [Color("HomeViewGradientPrimary").opacity(0.6), Color("HomeViewGradientSecondary").opacity(0)], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: .circle
        )
        .glassEffect(.clear.interactive(), in: .circle)
    }

    private var expiringSoonSection: some View {
        Section {
            if !productVM.hasLoadedProducts {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if expiringProducts.isEmpty {
                Text("Nothing expiring in the next few days")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(expiringProducts.prefix(expiringSoonLimit)) { product in
                    ProductRowView(product: product)
                }
            }
        } header: {
            HStack {
                Text("Expiring Soon")
                Spacer()
                if !expiringProducts.isEmpty {
                    // TODO: open Inventory filtered to expiring products once it has an expiry filter
                    Button("See All (\(expiringProducts.count))") {
                        selectedTab = .inventory
                    }
                }
            }
            .foregroundStyle(.white.opacity(0.9))
        }
    }
}

#if DEBUG
#Preview(traits: .appEnvironment) {
    HomeView(selectedTab: .constant(.home))
}
#endif
