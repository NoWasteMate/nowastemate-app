//
//  JoinFamilyView.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 30/11/2025.
//

import SwiftUI

struct FamilyView: View {
    
    @EnvironmentObject var familyVM: FamilyViewModel
    
    @State private var isClicked: Bool = false
    
    var body: some View {
        
        ZStack {
            
            //https://medium.com/push-2-prod/gradients-in-swiftui-e3481685cb9d
            //making it span entire screen
            LinearGradient(gradient: Gradient(colors: [.white, .white, .cyan]), startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 24) {
                
            
                
                           
                Text("Eliminate Waste as a family")
                    //https://sarunw.com/posts/swiftui-text-font/
                    .font(.title)
                    .foregroundColor(.black)
                    .padding(.bottom, 20)
                
                HStack{
                    
                    Text("Let others join you, simply share the code below?")
                    //https://sarunw.com/posts/swiftui-text-font/
                        .font(
                            .headline
                                .weight(.bold)
                            
                        )
                        .foregroundColor(.black)
                    
                    
                }
                
                HStack {
                
                    if let family = familyVM.familyId {
                        Text("\(family)")
                    } else if let errorMessage = familyVM.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    } else {
                        Text("Loading Invite Code")
                            .onAppear {
                                familyVM.findFamilyId()
                            }
                    }
                
                
                    
                    //https://sarunw.com/posts/swiftui-image-button/
                    if let familyId = familyVM.familyId {
                        Button {
                            isClicked = true
                            UIPasteboard.general.string = "I would like for you to join my family on NoWasteMate, please join using code:\n \(familyId)"
                        } label: {
                            Image(systemName: "doc.on.clipboard")
                                        .foregroundColor(.gray)
                                        .imageScale(.small)
                        }
                        
                    }
                    
                }
                
                
                //https://www.devfright.com/how-to-add-tap-to-copy-with-uipasteboard-in-swiftui/
                if isClicked {
                    Text("Copied!")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.8))
                                        .foregroundColor(.white)
                                        .cornerRadius(6)
                                        .transition(.opacity.combined(with: .move(edge: .top)))

                }
                
                

                //title
                Text("Are you looking to join your family in eliminating waste?")
                    //https://sarunw.com/posts/swiftui-text-font/
                    .font(
                            .headline
                            .weight(.bold)

                        )
                    .foregroundColor(.black)
                
                NavigationLink("Join a Family", destination: JoinFamilyView())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(30)
                
                
                Text("Ready to start your own family?")
                    //https://sarunw.com/posts/swiftui-text-font/
                    .font(
                            .headline
                            .weight(.bold)

                        )
                    .foregroundColor(.black)
                
                NavigationLink("Start a Family", destination: CreateFamilyView())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(30)
                
            }
            .padding(.horizontal, 30)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    FamilyView()
}
