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
    @EnvironmentObject var analyticsVM: AnalyticsViewModel
    
    @Binding var selectedTab: RootTab

    @State private var showsWasteOverview = false

    private let likelyToWasteLimit = 5
    private let riskOrder: [WasteRisk] = [.high, .medium, .low]
    private let scoreCircleSize: CGFloat = 224
    
    // The family score is only shown on the Waste overview
    private var userScore: WasteScore? {
        analyticsVM.wasteScore?.user
    }

    private var scoreTint: Color {
        guard let rating = userScore?.rating else { return Color("HomeViewGradientPrimary") }
        return Color(rating.colorName)
    }

    private var scoreText: String {
        guard let score = userScore?.score else { return "—" }
        return "\(score)"
    }

    private var scoreCaption: String {
        guard let userScore else { return "Couldn't load your score" }

        let productsNeeded = userScore.productsNeeded
        if productsNeeded > 0 {
            let noun = productsNeeded == 1 ? "product" : "products"
            return "Mark \(productsNeeded) more \(noun) to get your score"
        }
        return userScore.rating?.displayName ?? ""
    }

    // Highest risk first, then closest to expiring. Fresh low risk products are left out
    private var likelyToWasteProducts: [Product] {
        productVM.products
            .filter { $0.expiryStatus() != .fresh || wasteRisk(of: $0) != .low }
            .sorted { first, second in
                let firstRank = riskOrder.firstIndex(of: wasteRisk(of: first)) ?? 0
                let secondRank = riskOrder.firstIndex(of: wasteRisk(of: second)) ?? 0
                if firstRank != secondRank {
                    return firstRank < secondRank
                }
                return (first.daysUntilExpiry() ?? 0) < (second.daysUntilExpiry() ?? 0)
            }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.editUserDarkGradient, .editUserLightGradient]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
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

                        Text("Your Waste Score")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    
                    NavigationLink {
                        WasteOverviewView()
                    }
                    label: {
                        Image(systemName: "chart.xyaxis.line")
                            .foregroundColor(.white)
                            .imageScale(.small)
                            .padding()
                            .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 30))
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
                        wasteScoreCircle
                            .onTapGesture {
                                showsWasteOverview = true
                            }
                        .frame(maxWidth: .infinity, minHeight: 264)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                    }

                    likelyToWasteSection
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
               
                .listRowSpacing(12)
                .padding(.horizontal, -20)
            }
            .padding([.horizontal, .top], 26)
        }
        // A NavigationLink would make the whole List row tappable
        // https://www.createwithswift.com/programmatic-navigation-with-navigation-destination-in-swiftui/
        .navigationDestination(isPresented: $showsWasteOverview) {
            WasteOverviewView()
        }
        .onAppear{
            if authVM.userInfo == nil {
                authVM.findUser()
            } else {
                authVM.newDietaryRestrictions = authVM.userInfo?.dietaryRestrictions ?? []
            }
            // Only Inventory and Recipes loaded products before, so load here since neither have been opened yet
            if !productVM.hasLoadedProducts, let user = authVM.user {
                productVM.loadProducts(for: user)
            }
            // Every appear so the score refreshes after marking a product
            if let user = authVM.user {
                analyticsVM.loadWasteScore(for: user)
                analyticsVM.loadWasteRisks(for: user, family: false)
            }
            
            NotificationService.shared.requestAuth()
        }
    }
    
    private var wasteScoreCircle: some View {
        VStack {
            // No summary and no error yet means the first load hasn't returned
            if userScore == nil && analyticsVM.scoreErrorMessage == nil {
                ProgressView()
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(scoreText)
                        .font(.system(size: 64, weight: .bold))
                    if userScore?.score != nil {
                        Text("pts")
                            .font(.title3)
                    }
                }
                Text(scoreCaption)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
        }
        .foregroundStyle(.white)
        .frame(width: scoreCircleSize, height: scoreCircleSize)
        .background(
            LinearGradient(colors: [scoreTint.opacity(0.6), Color("HomeViewGradientSecondary").opacity(0)], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: .circle
        )
        .glassEffect(.clear.interactive(), in: .circle)
    }

    private var likelyToWasteSection: some View {
        Section {
            if !productVM.hasLoadedProducts {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if likelyToWasteProducts.isEmpty {
                Text("Nothing likely to go to waste right now")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(likelyToWasteProducts.prefix(likelyToWasteLimit)) { product in
                    ProductRowView(product: product)
                }
            }
        } header: {
            HStack {
                Text("Likely to Waste")
                Spacer()
                if !likelyToWasteProducts.isEmpty {
                    // TODO: open Inventory filtered to expiring products once it has an expiry filter
                    Button("See All (\(likelyToWasteProducts.count))") {
                        selectedTab = .inventory
                    }
                }
            }
            .foregroundStyle(.white.opacity(0.9))
        }
    }
    
    // Products the backend has no risk for count as low
    private func wasteRisk(of product: Product) -> WasteRisk {
        analyticsVM.wasteRisks.first { $0.id == product.id }?.risk ?? .low
    }
}

#if DEBUG
#Preview(traits: .appEnvironment) {
    HomeView(selectedTab: .constant(.home))
}
#endif
