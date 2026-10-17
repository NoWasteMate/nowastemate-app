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
            
            VStack(alignment: .leading, spacing: 24) {
                
                Section {
                    VStack {
                        
                        Text("Waste by Category")
                        //https://sarunw.com/posts/swiftui-text-font/
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(.bottom, 20)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                        
                        
                        //https://www.hackingwithswift.com/forums/swiftui/swiftui-foreach-iterating-over-an-array-of-key-value-pairs/21069
                        if let categories = analyticsVM.categoryWasteResults?.sorted(by: {$0.value > $1.value}) {
                            ForEach(categories, id: \.key) { key, value in
                                HStack {
                                    Text(key.capitalized).foregroundStyle(Color.white)
                                    
                                    Spacer()
                                    //https://www.reddit.com/r/SwiftUI/comments/wbl7vh/double_in_text_with_1_decimal/
                                    //https://www.swiftbysundell.com/articles/formatting-numbers-in-swift/
                                    let str = String(format: "%.1f", value)
                                    
                                    HStack {
                                        Text("\(str)%").foregroundStyle(Color.white)
                                    }
                                    
                                    
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .glassEffect(.clear, in: .rect(cornerRadius: 10))                  .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.white, lineWidth: 1)
                                )
                                .padding(.horizontal, 12)
                            }
                        } else if let message = analyticsVM.categoryWasteErrorMessage {
                            Text(message)
                                .foregroundStyle(Color.white)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 164)
                    
                    
                }
                
            }
            .padding(.horizontal, 30)
            .onAppear{
                guard let user = authVM.user else { return }
                analyticsVM.categoryWaste(for: user, familyId: nil)
            }
        }
    }
}

#if DEBUG
#Preview(traits: .appEnvironment) {
    CategoryWasteView()
}
#endif
