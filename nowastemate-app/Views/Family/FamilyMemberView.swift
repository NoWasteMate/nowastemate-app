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
        LinearGradient(gradient: Gradient(colors: [.white, .white, .yellow]), startPoint: .top, endPoint: .bottom)
        
        VStack(alignment: .leading, spacing: 24) {

            //title

            VStack(spacing: 8) {
                
                Text("Current Family Members")
                    .font(.title)
                    .foregroundColor(.black)
                    .padding(.bottom, 20)
                
                //https://medium.com/@jpmtech/swiftui-list-from-beginner-to-merlin-5308261b78b6
                //https://sarunw.com/posts/swiftui-list-with-foreach/
                if familyVM.familyMembers != nil {
                    
                    VStack {
                        
                        List(familyVM.familyMembers!, id: \.self) { item in
                            Text(item)
                            
                            
                            
                        }
                    }
                } else if let errorMessage = familyVM.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else {
                    Text("Loading Family Members")
                }
                
            }
            .padding()
            
        }
    }
    .onAppear {
        familyVM.findFamilyMembers()
    }
}
}


#Preview {
    FamilyMemberView()
}
