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
                        
                    Text("Add Family Members with This Code:")
                        //https://sarunw.com/posts/swiftui-text-font/
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                    
                    HStack {
                    
                        if let family = familyVM.familyId {
                            Text("\(family)")
                                .foregroundStyle(Color.white)
                                .padding()
                        } else if let errorMessage = familyVM.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        } else {
                            Text("Loading Invite Code")
                                .padding()
                        }
                
                        
                        
                        
                        //https://sarunw.com/posts/swiftui-image-button/
                        if let familyId = familyVM.familyId {
                            Button {
                                isClicked = true
                                UIPasteboard.general.string = "\(familyId)"
                            } label: {
                                Image(systemName: "doc.on.clipboard")
                                            .foregroundColor(.white)
                                            .imageScale(.small)
                                            .padding()
                            }
                            
                        }
                        
                    }
                    //https://stackoverflow.com/questions/71744888/how-to-make-a-swiftui-view-with-rounded-corners-and-a-border
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white, lineWidth: 2)
                    )
                    
                    
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
                    Button("Save Family"){
                        
                        if (isFormValid){
                            
                            familyVM.createFamily(title: title)
                            
                            
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
