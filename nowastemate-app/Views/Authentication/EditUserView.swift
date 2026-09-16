//
//  EditUserView.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 15/09/2026.
//

import SwiftUI

struct EditUserView: View {
    
    //state variables for user input
    @State private var email = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var dietaryRestrictions = ""
    
    var isFormValid: Bool {
        !email.isEmpty && !firstName.isEmpty && !lastName.isEmpty
    }
    
    @State private var showAlert = false
    @State private var alertMessage = ""


    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            
            //https://medium.com/push-2-prod/gradients-in-swiftui-e3481685cb9d
            //making it span entire screen
            LinearGradient(gradient: Gradient(colors: [.editUserDarkGradient, .editUserLightGradient]), startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 24) {

                //title
                Text("Update Information")
                    //https://sarunw.com/posts/swiftui-text-font/
                    .font(
                            .largeTitle
                            .weight(.medium)
                        )
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .frame(maxWidth: .infinity)
                    .symbolVariant(.circle)
                    .foregroundStyle(.white)

                VStack(spacing: 8) {
                    
                    Text("First Name")
                        .font(.headline)
                        .foregroundColor(Color.white)

                    TextField("", text: $firstName)
                        .foregroundStyle(Color.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.white, lineWidth: 1)
                        )
                    
                    Text("Last Name")
                        .font(.headline)
                        .foregroundColor(Color.white)

                    TextField("", text: $lastName)
                        .foregroundStyle(Color.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.white, lineWidth: 1)
                        )
                    
                    Text("Dietary Restrictions?")
                    .font(.headline)
                    .foregroundColor(Color.white)


                    TextField("", text: $dietaryRestrictions)
                        .foregroundStyle(Color.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.white, lineWidth: 1)
                        )
                    
                    Text("Email")
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .bold()

                    TextField("", text: $email)
                        .textInputAutocapitalization(.never)
                        .foregroundStyle(Color.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.white, lineWidth: 1)
                        )
                    
                    Button(!isFormValid ? "Please enter new details" : isFormValid ? "Save" : "Please enter new details"){
                      
                          guard isFormValid else {
                              alertMessage = "Please enter your details."
                              showAlert = true
                              return
                          }
                      
                        // error.localizedDescription is Firebase's user-presentable error message https://firebase.google.com/docs/auth/ios/errors
                        //authVM.editRequest(email: email, firstName: firstName, lastName: lastName, dietaryRestrictions: dietaryRestrictions) { error in
                        //    if let error = error {
                        //        alertMessage = error.localizedDescription
                        //        showAlert = true
                                
                        //    } else {
                        //        dismiss()
                        //    }
                        //}
                    }
                    .disabled(!isFormValid)

                    //https://developer.apple.com/documentation/swiftui/alert
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Incorrect Input"),
                            message: Text(alertMessage)
                        )

                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(!isFormValid ? .gray : isFormValid ? .black : .gray)
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
    EditUserView()
}
