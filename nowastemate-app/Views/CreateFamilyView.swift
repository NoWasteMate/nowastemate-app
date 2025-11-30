//
//  CreateFamilyView.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 30/11/2025.
//

import SwiftUI

struct CreateFamilyView: View {
    
    //state variables for user input
    @State private var name: String = ""
    
    @EnvironmentObject var familyVM: FamilyViewModel
    
    var isFormValid: Bool {
            !name.isEmpty
    }
    
    @State private var showAlert = false
    

    var body: some View {
        ZStack {
            
            //https://medium.com/push-2-prod/gradients-in-swiftui-e3481685cb9d
            //making it span entire screen
            LinearGradient(gradient: Gradient(colors: [.white, .white, .yellow]), startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 24) {

                //title
                Text("Create a Family and manage groceries together!")
                    //https://sarunw.com/posts/swiftui-text-font/
                    .font(
                            .largeTitle
                            .weight(.bold)

                        )
                    .foregroundColor(.black)

                VStack(spacing: 8) {
                    
                    Text("Family Name")
                        .font(.headline)
                        .foregroundColor(Color.black)

                    TextField("", text: $name)
                        .padding()
                        .background(Color.white)
                        .border(Color.gray)
                        .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(.gray, lineWidth: 2)
                        )
                    
                    

                    Button("Create Family"){
                        
                        if (isFormValid){
                            
                            familyVM.createFamily(name: name)
                            
                            
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

#Preview {
    CreateFamilyView()
}
