//
//  JoinFamilyView.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 30/11/2025.
//

import SwiftUI

struct JoinFamilyView: View {
    //state variables for user input
    @State private var code: String = ""
    
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var familyVM: FamilyViewModel
    
    var isFormValid: Bool {
        !code.isEmpty
    }
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showAlert = false
    
    
    var body: some View {
        ZStack {
            
            //https://medium.com/push-2-prod/gradients-in-swiftui-e3481685cb9d
            //making it span entire screen
            LinearGradient(gradient: Gradient(colors: [.familyViewLightGradient,.familyViewDarkGradient]), startPoint: .top, endPoint: .bottom)

                VStack(alignment: .leading, spacing: 24) {
                                        
                    //title
                    Text("You’re not a Part of Any Family Yet")
                    //https://sarunw.com/posts/swiftui-text-font/
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 8) {
                        //https://stackoverflow.com/questions/57688242/swiftui-how-to-change-the-placeholder-color-of-the-textfield
                        TextField("", text: $code, prompt: Text("Enter Family Code").foregroundColor(.white))
                            .padding()
                            .background(Color.white.opacity(0.5))
                            .border(Color.gray)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(.white, lineWidth: 2)
                            )
                            .cornerRadius(12)
                        
                        Button("Join Family"){
                            
                            if (isFormValid){
                                
                                if let user = authVM.user {
                                    familyVM.findNewFamily(for: user, code: code)
                                }
                                
                                dismiss()
                                
                            } else {
                                showAlert = true
                            }
                        }
                        .disabled(!isFormValid)
                        
                        //https://developer.apple.com/documentation/swiftui/alert
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("Missing Input"),
                                message: Text("Please fill in the information required")
                            )
                            
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(30)
                        .padding(.top)
                        
                        Text("Please have the family owner share their code with you.")
                            //https://sarunw.com/posts/swiftui-text-font/
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                        
                        //TODO: Add button with FAQ
                        
                        
                        
                    }
                    .padding()
                }
                .padding(.horizontal, 30)
            }
            .edgesIgnoringSafeArea(.all)
            
        }
    }


#if DEBUG
#Preview(traits: .appEnvironment) {
    JoinFamilyView()
}
#endif
