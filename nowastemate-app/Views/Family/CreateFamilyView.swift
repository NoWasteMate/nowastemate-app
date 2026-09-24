//
//  CreateFamilyView.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 30/11/2025.
//

import SwiftUI

struct CreateFamilyView: View {
    
    //state variables for user input
    @State private var title: String = ""
    
    @EnvironmentObject var familyVM: FamilyViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isClicked: Bool = false
    
    var isFormValid: Bool {
            !title.isEmpty
    }
    
    @State private var showAlert = false
    

    var body: some View {
        ZStack {
            
            //https://medium.com/push-2-prod/gradients-in-swiftui-e3481685cb9d
            //making it span entire screen
            LinearGradient(gradient: Gradient(colors: [.familyViewLightGradient,.familyViewDarkGradient]), startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 24) {

                //title
                Text("Manage Your Groceries Together!")
                    //https://sarunw.com/posts/swiftui-text-font/
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)

                VStack(spacing: 8) {
                    
                    Text("Create a Family Name")
                        //https://sarunw.com/posts/swiftui-text-font/
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                    

                    TextField("", text: $title)
                        .padding()
                        .background(Color.white.opacity(0.5))
                        .border(Color.gray)
                        .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(.white, lineWidth: 2)
                        )
                        .cornerRadius(12)
                        
                    
                    Button("Save Family"){
                        
                        if (isFormValid){
                            
                            familyVM.createFamily(title: title)
                            
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
    CreateFamilyView()
}
#endif
