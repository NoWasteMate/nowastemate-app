//
//  LeaderboardView.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 15/11/2026.
//

import SwiftUI
import FirebaseAuth

struct LeaderboardView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var analyticsVM: AnalyticsViewModel
    
    
    
    //check if user is alone
    var isAlone: Bool {
        analyticsVM.familyLeaderboard?.count == 1 && analyticsVM.familyLeaderboard != nil
    }
    

    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.editUserDarkGradient, .editUserLightGradient]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            if analyticsVM.familyLeaderboard != nil && !isAlone {
                
                ScrollView {
                    Section {
                        VStack {
                            
                            Text("Family Leaderboard")
                            //https://sarunw.com/posts/swiftui-text-font/
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(.vertical, 40)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                            
                            
                            
                            //https://www.hackingwithswift.com/forums/swiftui/swiftui-foreach-iterating-over-an-array-of-key-value-pairs/21069
                            if let members = analyticsVM.familyLeaderboard?.sorted(by: {$0.score ?? 0 > $1.score ?? 0}) {
                                
                                
                                                                
                                ForEach(members) { member in
                                    
                                    if (member.score != nil){
                                        
                                        HStack {
                                            
                                            if (members[0] == member){
                                                Text(String(1)).bold().foregroundStyle(.white)
                                            }
                                            if (members[1] == member) {
                                                Text(String(2)).bold().foregroundStyle(.white)
                                            }
                                            //in case there is only 2 in family
                                            if (members.count > 2 && members[2] == member) {
                                                Text(String(3)).bold().foregroundStyle(.white)
                                            }
                                            
                                            
                                            Text("\(member.firstName) \(member.lastName)").foregroundStyle(Color.white)
                                            
                                            Spacer()
                                            
                                            Text("\(member.score ?? 0)").foregroundStyle(Color.white)
                                        }
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
                                    
                            
                            //https://www.programiz.com/swift-programming/library/dictionary/contains
                            
                                    
                                    if (members.contains(where: {$0.score == nil})){
                                        
                                        DisclosureGroup("Notes"){
                                            
                                            VStack (spacing: 10){
                                                
                                                if members.contains(where: {$0.id != authVM.user?.uid && $0.score == nil }) {
                                                    Text("Some Family Members do not have enough products logged and have been omitted")
                                                        .padding()
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .stroke(.white, lineWidth: 1))
                                                }
                                                
                                                
                                                if members.contains(where: {$0.id == authVM.user?.uid && $0.score == nil }) {
                                                    Text("Your user does not have enough products logged and has been omitted")
                                                        .padding()
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .stroke(.white, lineWidth: 1))
                                                    
                                                }
                                            }.foregroundStyle(.white).font(.footnote)
                                                .padding()
                                        
                                        }
                                        .padding()
                                        .foregroundStyle(.white)
                                        //TODO: Fix color on the tab
                                        .tint(.white)
                                    }
                                    
                                
                                
                            } else if let message = analyticsVM.categoryWasteErrorMessage {
                                Text(message)
                                    .foregroundStyle(Color.white)
                            }
                            
                            
                            
                        }
                        .frame(maxWidth: .infinity, minHeight: 164)
                        
                        
                    }
                }
            } else if isAlone {
                VStack {
                    Text("You are alone in your Family").foregroundStyle(.white).font(.title)
                        .padding()
                    Text("Add Family Members to see the leaderboard").foregroundStyle(.white)
                        .padding()
                }
                
            }
            else {
                ProgressView().tint(.white)
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
