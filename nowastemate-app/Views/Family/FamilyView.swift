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
            LinearGradient(gradient: Gradient(colors: [.familyViewLightGradient,.familyViewDarkGradient]), startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 24) {
                
            
                
                
                Text("Eliminate Waste as a Family")
                    //https://sarunw.com/posts/swiftui-text-font/
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                                
                /*
                NavigationLink("View Current Family Members", destination: FamilyMemberView())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(30)
                 */
                //https://www.createwithswift.com/using-sf-symbols-in-swiftui/
                //https://www.codegenes.net/blog/clip-image-to-square-in-swiftui/
                Image(systemName: "person.3")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .symbolVariant(.fill)
                    .foregroundStyle(.white)
                
                
                NavigationLink("Create Family", destination: CreateFamilyView())
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(30)
                    .bold()
                
                NavigationLink("Join Family", destination: JoinFamilyView())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical)
                    .background(Color.buttonBackgroundPrimary)
                    .cornerRadius(32)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, 30)
                        
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            familyVM.findFamilyId()
        }
        
    }
}

#Preview {
    FamilyView()
}
