//
//  JoinFamilyView.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 30/11/2025.
//

import SwiftUI

struct FamilyView: View {
    var body: some View {
        
        ZStack {
            
            //https://medium.com/push-2-prod/gradients-in-swiftui-e3481685cb9d
            //making it span entire screen
            LinearGradient(gradient: Gradient(colors: [.white, .white, .cyan]), startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 24) {
                
                Text("Eliminate Waste as a family")
                    //https://sarunw.com/posts/swiftui-text-font/
                    .font(
                        .title
                        )
                    .foregroundColor(.black)
                    .padding(.bottom, 20)
                

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
