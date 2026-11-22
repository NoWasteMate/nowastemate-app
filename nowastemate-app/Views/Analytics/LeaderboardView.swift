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
            LinearGradient(gradient: Gradient(colors: [.familyViewLightGradient, .familyViewDarkGradient]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            if analyticsVM.familyLeaderboard != nil && !isAlone {
                
                ScrollView {
                    Section {
                        VStack {
                            
                            VStack (spacing: 20) {
                                
                                Text("Family Leaderboard")
                                //https://sarunw.com/posts/swiftui-text-font/
                                    .font(.largeTitle).bold()
                                    .foregroundColor(Color.baseText)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                
                                Image(systemName: "trophy.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .frame(maxWidth: .infinity)
                                    .symbolVariant(.circle)
                                    .foregroundStyle(Color.baseText)
                                    .padding(.bottom, 20)
                                
                            }
                            
                            
                            
                            //https://www.hackingwithswift.com/forums/swiftui/swiftui-foreach-iterating-over-an-array-of-key-value-pairs/21069
                            if let members = analyticsVM.familyLeaderboard?.sorted(by: {$0.score ?? 0 > $1.score ?? 0}) {
                                
                                
                                                                
                                ForEach(members) { member in
                                    
                                    if (member.score != nil){
                                        
                                        HStack {
                                            
                                            if (members[0] == member){
                                                Text(String(1)).bold().foregroundStyle(Color.baseText)
                                                    .font(.title)
                                                
                                                Text("\(member.firstName) \(member.lastName)").foregroundStyle(Color.baseText)
                                                    .font(.title)

                                                Spacer()
                                                
                                                Text("\(member.score ?? 0)").foregroundStyle(Color.baseText)
                                                    .font(.title)

                                                
                                                Text("pts")
                                                    .foregroundStyle(Color.baseText)
                                                    .font(.footnote)
                                            }
                                            else if (members[1] == member) {
                                                Text(String(2)).bold().foregroundStyle(Color.baseText)
                                                    .font(.title2)

                                                
                                                Text("\(member.firstName) \(member.lastName)").foregroundStyle(Color.baseText)
                                                    .font(.title2)

                                                
                                                Spacer()
                                                
                                                Text("\(member.score ?? 0)").foregroundStyle(Color.baseText)
                                                    .font(.title2)

                                                
                                                Text("pts")
                                                    .foregroundStyle(Color.baseText)
                                                    .font(.footnote)

                                            }
                                            //in case there is only 2 in family
                                            else if (members.count > 2 && members[2] == member) {
                                                Text(String(3)).bold().foregroundStyle(Color.baseText)
                                                    .font(.title3)

                                                
                                                Text("\(member.firstName) \(member.lastName)").foregroundStyle(Color.baseText)
                                                    .font(.title3)

                                                
                                                Spacer()
                                                
                                                Text("\(member.score ?? 0)").foregroundStyle(Color.baseText)
                                                    .font(.title3)

                                                
                                                Text("pts")
                                                    .foregroundStyle(Color.baseText)
                                                    .font(.footnote)
                                            }
                                            
                                            else {
                                                Text("\(member.firstName) \(member.lastName)").foregroundStyle(Color.baseText)
                                                
                                                Spacer()
                                                
                                                Text("\(member.score ?? 0)").foregroundStyle(Color.baseText)
                                                
                                                Text("pts")
                                                    .foregroundStyle(Color.baseText)
                                                    .font(.footnote)
                                            }
                                            
                                        }
                                        

                                        
                                    }
                                        
                                    }
                                    .foregroundColor(Color.baseText).bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .cornerRadius(12)
                                    
                                    .glassEffect(.clear.interactive().tint(Color("CardColor")), in:.rect(cornerRadius: 12))
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
                                                                .stroke(Color.baseText, lineWidth: 1))
                                                }
                                                
                                                
                                                if members.contains(where: {$0.id == authVM.user?.uid && $0.score == nil }) {
                                                    Text("Your user does not have enough products logged and has been omitted")
                                                        .padding()
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .stroke(Color.baseText, lineWidth: 1))
                                                    
                                                }
                                            }.foregroundStyle(Color.baseText).font(.footnote)
                                                .padding()
                                        
                                        }
                                        .padding()
                                        .foregroundStyle(Color.baseText)
                                        //TODO: Fix color on the tab
                                        .tint(Color.baseText)
                                    }
                                    
                                
                                
                            } else if let message = analyticsVM.categoryWasteErrorMessage {
                                Text(message)
                                    .foregroundStyle(.red)
                            }
                            
                            
                            
                        }
                        .frame(maxWidth: .infinity, minHeight: 164)
                        
                        
                    }
                }
            } else if isAlone {
                VStack {
                    Text("You are alone in your Family").foregroundStyle(Color.baseText).font(.title)
                        .padding()
                    Text("Add Family Members to see the leaderboard").foregroundStyle(Color.baseText)
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
