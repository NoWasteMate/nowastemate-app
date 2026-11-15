//
//  LeaderboardView.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 15/11/2026.
//

import SwiftUI

struct LeaderboardView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var analyticsVM: AnalyticsViewModel

    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.editUserDarkGradient, .editUserLightGradient]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            ScrollView {
                Section {
                    VStack {
                        
                        Text("Family Leaderboard")
                        //https://sarunw.com/posts/swiftui-text-font/
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(.bottom, 20)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                        

                        
                        //https://www.hackingwithswift.com/forums/swiftui/swiftui-foreach-iterating-over-an-array-of-key-value-pairs/21069
                        if let members = analyticsVM.familyLeaderboard?.sorted(by: {$0.score ?? 0 > $1.score ?? 0}) {
                            ForEach(members) { member in
                                HStack {
                                    
                                    Text("\(member.firstName) \(member.lastName)").foregroundStyle(Color.white)
                                    
                                    Spacer()
                                    
                                    Text("\(member.score ?? 0)").foregroundStyle(Color.white)
                                    
                                    
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
            
        }
        .onAppear{
            guard let user = authVM.user else { return }
            
            analyticsVM.familyLeaderboard(for: user)
        }
    }
}

#Preview {
    LeaderboardView()
}
