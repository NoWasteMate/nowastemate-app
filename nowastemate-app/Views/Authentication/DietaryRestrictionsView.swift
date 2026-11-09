//
//  DietaryRestrictionsView.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 08/11/2026.
//

//references
//https://www.reddit.com/r/SwiftUI/comments/1c7humg/view_to_display_all_cases_of_an_enum/
//https://sarunw.com/posts/swiftui-checkbox/
//https://www.geeksforgeeks.org/swift/how-to-check-if-the-set-contains-a-given-element-in-swift/

import SwiftUI

struct DietaryRestrictionsView: View {
    
    @State var restrictions: Set<DietaryRestrictions> = []
    
    @EnvironmentObject var authVM: AuthViewModel

    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        ZStack {
            
            //https://medium.com/push-2-prod/gradients-in-swiftui-e3481685cb9d
            //making it span entire screen
            LinearGradient(gradient: Gradient(colors: [.editUserDarkGradient, .editUserLightGradient]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    
                    Spacer()
                    
                    //title
                    Text("Select Dietary Restrictions")
                    //https://sarunw.com/posts/swiftui-text-font/
                        .font(
                            .title.weight(.medium)
                        )
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top)
                    
                    Image(systemName: "fork.knife")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .frame(maxWidth: .infinity)
                        .symbolVariant(.circle)
                        .foregroundStyle(.white)
                    
                    Text("Select any that apply below")
                    //https://sarunw.com/posts/swiftui-text-font/
                        .font(
                            .subheadline.bold()
                        )
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top)
                    
                    
                ScrollView {

                    
                    VStack(spacing: 15) {
                        
                        
                        ForEach(DietaryRestrictions.allCases) { choice in
                            HStack {
                                
                                Button {
                                    
                                    if (restrictions.contains(choice)) {
                                        restrictions.remove(choice)
                                    } else {
                                        restrictions.insert(choice)
                                    }
                                    
                                    
                                } label: {
                                    
                                    Text(choice.rawValue)
                                    
                                    Spacer()
                                    
                                    Image(systemName: restrictions.contains(choice) ? "checkmark.circle" : "circle")
                                        .foregroundColor(.white)
                                        .imageScale(.small)
                                }
                            }.foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        }
                        
                    }
                    .padding()
                }
                .padding(.horizontal, 30)
                    
                Button("Confirm"){
                    
                    let choices = Array(restrictions)
                    
                    authVM.newDietaryRestrictions = choices
                    
                    dismiss()
                    
                    print(authVM.newDietaryRestrictions)
                    
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(.white)
                    .cornerRadius(30)
                    .padding()
            }
                .onAppear {
                    restrictions = Set(authVM.newDietaryRestrictions)
                }
            
        }
    }
}


#Preview {
    DietaryRestrictionsView()
}



