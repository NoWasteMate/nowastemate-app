//
//  SignUpView.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 15/11/2025.
//

//general ref: previous project where we also did user signup

import SwiftUI

struct SignUpView: View {
    
    //state variables for user input
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var dietaryRestrictions = ""
    
    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && !firstName.isEmpty && !lastName.isEmpty
    }
    
    @State private var showAlert = false
    @State private var alertMessage = ""


    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            
            //https://medium.com/push-2-prod/gradients-in-swiftui-e3481685cb9d
            //making it span entire screen
            LinearGradient(gradient: Gradient(colors: [.userManagementBrown, .offWhite, .offWhite, .offWhite, .userManagementBrown]), startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 24) {

                //title
                Text("Sign Up Today")
                    //https://sarunw.com/posts/swiftui-text-font/
                    .font(
                            .largeTitle
                            .weight(.medium)
                        )
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)

                VStack(spacing: 8) {
                    
                    Text("First Name")
                        .font(.headline)
                        .foregroundColor(Color.foreGroundBrown)

                    TextField("", text: $firstName)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    
                    Text("Last Name")
                        .font(.headline)
                        .foregroundColor(Color.foreGroundBrown)

                    TextField("", text: $lastName)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    
                    Text("Dietary Restrictions?")
                    .font(.headline)
                    .foregroundColor(Color.foreGroundBrown)


                    TextField("", text: $dietaryRestrictions)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    
                    Text("Email")
                        .font(.headline)
                        .foregroundColor(Color.foreGroundBrown)
                        .bold()

                    TextField("", text: $email)
                        .textInputAutocapitalization(.never)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    
                    Text("Password")
                        .font(.headline)
                        .foregroundColor(Color.foreGroundBrown)

                    SecureField("", text: $password)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        

                    Text("Repeat Password")
                        .font(.headline)
                        .foregroundColor(Color.foreGroundBrown)

                    //https://stackoverflow.com/questions/77755756/how-to-add-a-border-in-swiftui-with-clipshape
                    //adding the rounded border
                    SecureField("", text: $confirmPassword)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray, lineWidth: 1)
                        )


                    Button(!isFormValid ? "Please enter your details" : isFormValid ? "Sign Up" : "Please enter your details"){
                      
                          guard isFormValid else {
                              alertMessage = "Please enter your details."
                              showAlert = true
                              return
                          }

                          guard password == confirmPassword else {
                              alertMessage = "Password inputs must match!"
                              showAlert = true
                              return
                          }

                          // Firebase requires a 6 character minimum password: https://firebase.google.com/docs/auth/ios/password-auth
                          guard password.count >= 6 else {
                              alertMessage = "Password must be at least 6 characters."
                              showAlert = true
                              return
                          }
                      
                        // error.localizedDescription is Firebase's user-presentable error message https://firebase.google.com/docs/auth/ios/errors
                        authVM.signUp(email: email, password: password, firstName: firstName, lastName: lastName, dietaryRestrictions: dietaryRestrictions) { error in
                            if let error = error {
                                alertMessage = error.localizedDescription
                                showAlert = true
                                
                            } else {
                                dismiss()
                            }
                        }
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


#if DEBUG
#Preview(traits: .appEnvironment) {
    SignUpView()
}
#endif
