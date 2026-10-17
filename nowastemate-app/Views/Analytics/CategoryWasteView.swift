//
//  CategoryWasteView.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 16/10/2026.
//



import SwiftUI

struct CategoryWasteView: View {
    
    
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var analyticsVM: AnalyticsViewModel
    

    var body: some View {
        ZStack {
            
            //https://medium.com/push-2-prod/gradients-in-swiftui-e3481685cb9d
            //making it span entire screen
            LinearGradient(gradient: Gradient(colors: [.familyViewLightGradient,.familyViewDarkGradient]), startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 24) {
                
                Section {
                    VStack {
                        
                        //https://www.hackingwithswift.com/forums/swiftui/swiftui-foreach-iterating-over-an-array-of-key-value-pairs/21069
                        if let categories = analyticsVM.categoryWasteResults?.sorted(by: {$0.value < $1.value}) {
                            ForEach(categories, id: \.key) { key, value in
                                HStack {
                                    Text(key)
                                    
                                    Spacer()
                                    Text("\(value)%")
                                    
                                    
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(.black, lineWidth: 1)
                                )
                                .padding(.horizontal, 12)
                            }
                        }
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
                
            }
            .padding(.horizontal, 30)
            .onAppear{
                guard let user = authVM.user else { return }
                analyticsVM.categoryWaste(for: user, familyId: nil)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#if DEBUG
#Preview(traits: .appEnvironment) {
    CategoryWasteView()
}
#endif
