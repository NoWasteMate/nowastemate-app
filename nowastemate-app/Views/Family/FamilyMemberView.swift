//
//  FamilyMemberView.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 06/12/2025.
//

import SwiftUI

struct FamilyMemberView: View {
    
    @EnvironmentObject var familyVM: FamilyViewModel
    
    var body: some View {

        ZStack {
            
            //https://medium.com/push-2-prod/gradients-in-swiftui-e3481685cb9d
            //making it span entire screen
            LinearGradient(gradient: Gradient(colors: [.familyViewLightGradient,.familyViewDarkGradient]), startPoint: .top, endPoint: .bottom)

            VStack(alignment: .leading, spacing: 24) {

                //title
                Text("Your Family")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom)

                VStack(spacing: 8) {
                    
                    HStack (spacing: 4) {
                        
                        Text("Family name")
                            .font(.title).bold()
                            .foregroundColor(.white)
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "pencil")
                                        .foregroundColor(.white)
                                        .imageScale(.small).bold()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    
                    
                    
                    //https://medium.com/@jpmtech/swiftui-list-from-beginner-to-merlin-5308261b78b6
                    //https://sarunw.com/posts/swiftui-list-with-foreach/
                    if familyVM.familyMembers != nil {
                        
                        ForEach(familyVM.familyMembers!, id: \.self) { item in
                            Button(item){}
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
                        
                    } else if let errorMessage = familyVM.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    } else {
                        Text("Loading Family Members")
                    }
                    
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color.white.opacity(0.5))
                        .padding(.horizontal, 12)
                )
            }
        }
        .onAppear {
            familyVM.findFamilyMembers()
        }
        .edgesIgnoringSafeArea(.all)

    }
}


#if DEBUG
#Preview(traits: .appEnvironment) {
    FamilyMemberView()
}
#endif
