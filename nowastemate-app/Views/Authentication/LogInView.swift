//
//  LogInView.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 15/11/2025.
//

import SwiftUI

struct LogInView: View {
    
    //state variables for user input
    @State private var email = ""
    @State private var password = ""
    
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var cameraVM: CameraViewModel
    
    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && isEmailValid && password.count >= 6
    }
    //ref: https://medium.com/@kalidoss.shanmugam/swift-ios-email-validation-best-practices-and-solutions-05456e265d2f
    //using regex to check for valid emails
    func isValidEmailComplex(_ email: String) -> Bool {
        //the required format
        let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        //checking if it fits format and returning true/false
        return emailPredicate.evaluate(with: email)
    }
    //this will update whenever the email changes, meaning it will live update as user is typing
    var isEmailValid: Bool {
        isValidEmailComplex(email)
    }
    
    var body: some View {
        
        ZStack {
            
            //https://medium.com/push-2-prod/gradients-in-swiftui-e3481685cb9d
            //making it span entire screen
            LinearGradient(gradient: Gradient(colors: [.userManagementBrown, .offWhite, .offWhite, .offWhite, .userManagementBrown]), startPoint: .top, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 24) {

                //title
                Text("Start Reducing Waste Today!")
                    //https://sarunw.com/posts/swiftui-text-font/
                    .font(
                            .largeTitle
                            .weight(.medium)
                        )
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)

                VStack(spacing: 16) {
                    Text("Email")
                        .font(.headline)
                        .foregroundColor(Color.foreGroundBrown)

                    TextField("", text: $email)
                        .textInputAutocapitalization(.never)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 5)
                        .foregroundStyle(.buttonBrown)

                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    if (!isEmailValid && !email.isEmpty){
                        Text("Please ensure you enter a valid email")
                            .font(.footnote)
                            .foregroundColor(Color.red)
                    }
                        

                    Text("Password")
                        .font(.headline)
                        .foregroundColor(Color.foreGroundBrown)

                    //https://stackoverflow.com/questions/77755756/how-to-add-a-border-in-swiftui-with-clipshape
                    //adding the rounded border
                    SecureField("", text: $password)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 5)
                        .foregroundStyle(.buttonBrown)

                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray, lineWidth: 1)
                        )

                    Button(action: {}) {
                        Text("Can’t Log In?")
                            .font(.subheadline)
                            .foregroundColor(.foreGroundBrown)
                            .underline()
                    }
                    .padding(.top, 6)

                    Button(!isFormValid ? "Please enter your details" : isFormValid ? "Sign In" : "Please enter your details"){
                        authVM.signIn(email: email, password: password)
                        //https://www.avanderlee.com/swiftui/swiftui-alert-presenting/
                        cameraVM.showClassificationTips = true
                    }.alert("Error", isPresented: $authVM.loginError, actions: {
                        
                    }, message: {
                        Text("Unable to Log In")
                    })
                    
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    //https://stackoverflow.com/questions/71446122/custom-coloring-with-if-else-in-swiftui Conditional coloring
                    .background(!isFormValid ? .gray : isFormValid ? .buttonBrown : .gray)
                    //https://sarunw.com/posts/swiftui-button-disable/
                    .disabled(!isFormValid)
                    .cornerRadius(30)
                   
                    NavigationLink("Sign Up", destination: SignUpView())
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(.black)
                        .cornerRadius(30)
                        .padding(.bottom)
                    
                }
                .padding()
                //https://stackoverflow.com/questions/65202061/swiftui-apply-background-color-to-rounded-rectangle
                .background(
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color.white.opacity(0.5))
                )
            }
            .padding(.horizontal, 30)
        }
        .edgesIgnoringSafeArea(.all)
    }
}


#if DEBUG
#Preview(traits: .appEnvironment) {
    LogInView()
}
#endif
