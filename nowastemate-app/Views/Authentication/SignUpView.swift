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
    //@State private var firstName = ""
    //@State private var lastName = ""
    
    var isFormValid: Bool {
            !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
    }
    
    @State private var showAlert = false
    @State private var alertMessage = ""


    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            
            //https://medium.com/push-2-prod/gradients-in-swiftui-e3481685cb9d
            //making it span entire screen
            LinearGradient(gradient: Gradient(colors: [.white, .white, .brown]), startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 24) {

                //title
                Text("Start Reducing Waste Today!")
                    //https://sarunw.com/posts/swiftui-text-font/
                    .font(
                            .largeTitle
                            .weight(.bold)

                        )
                    .foregroundColor(.black)

                VStack(spacing: 8) {
                    
                    //Text("First Name")
                    //    .font(.headline)
                    //    .foregroundColor(Color.brown)

                    //TextField("", text: $firstName)
                    //    .padding()
                    //    .background(Color.white)
                    //    .border(Color.gray)
                    //    .overlay(
                    //            RoundedRectangle(cornerRadius: 6)
                    //                .stroke(.gray, lineWidth: 2)
                    //    )
                    
                    //Text("Last Name")
                    //    .font(.headline)
                    //    .foregroundColor(Color.brown)

                    //TextField("", text: $lastName)
                    //    .padding()
                    //    .background(Color.white)
                    //    .border(Color.gray)
                    //    .overlay(
                    //            RoundedRectangle(cornerRadius: 6)
                    //                .stroke(.gray, lineWidth: 2)
                    //    )
                    
                    Text("Email")
                        .font(.headline)
                        .foregroundColor(Color.brown)

                    TextField("", text: $email)
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(Color.white)
                        .border(Color.gray)
                        .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(.gray, lineWidth: 2)
                        )
                    
                    Text("Password")
                        .font(.headline)
                        .foregroundColor(Color.brown)

                    SecureField("", text: $password)
                        .padding()
                        .background(Color.white)
                        .border(Color.gray)
                        .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(.gray, lineWidth: 2)
                        )
                        

                    Text("Confirm Password")
                        .font(.headline)
                        .foregroundColor(Color.brown)

                    //https://stackoverflow.com/questions/77755756/how-to-add-a-border-in-swiftui-with-clipshape
                    //adding the rounded border
                    SecureField("", text: $confirmPassword)
                        .padding()
                        .background(Color.white)
                        .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(.gray, lineWidth: 2)
                        )


                    Button(!isFormValid ? "Please enter your details" : isFormValid ? "Sign Up" : "Please enter your details"){
                      
                          guard isFormValid else {
                            alertMessage = "Please enter your details."
                            showAlert = true
                            return }

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

                          authVM.signUp(email: email, password: password)
                          dismiss()
                      
                        // error.localizedDescription is Firebase's user-presentable error message https://firebase.google.com/docs/auth/ios/errors
                        authVM.signUp(email: email, password: password) { error in
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
                    .frame(maxWidth: .infinity)
                    .padding()
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
    SignUpView()
}
