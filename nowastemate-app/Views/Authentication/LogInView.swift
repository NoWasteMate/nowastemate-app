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

    var body: some View {
        
        ZStack {
            
            //https://medium.com/push-2-prod/gradients-in-swiftui-e3481685cb9d
            //making it span entire screen
            LinearGradient(gradient: Gradient(colors: [.white, .white, .brown]), startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 24) {

                //title
                Text("Welcome Back!")
                    //https://sarunw.com/posts/swiftui-text-font/
                    .font(
                            .largeTitle
                            .weight(.bold)

                        )
                    .foregroundColor(.black)

                VStack(spacing: 16) {
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

                    //https://stackoverflow.com/questions/77755756/how-to-add-a-border-in-swiftui-with-clipshape
                    //adding the rounded border
                    SecureField("", text: $password)
                        .padding()
                        .background(Color.white)
                        .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(.gray, lineWidth: 2)
                        )
                        

                    Button(action: {}) {
                        Text("Can’t Log In?")
                            .font(.subheadline)
                            .foregroundColor(.brown)
                    }
                    .padding(.top, 6)

                    
                    
                    Button("Sign In"){
                        
                        

                        authVM.signIn(email: email, password: password)
                        //TODO: Navigation to new view
                        
                        
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brown)
                    .cornerRadius(30)
                    

                    NavigationLink("Sign Up", destination: SignUpView())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(30)
                    
                }
                .padding()
            }
            .padding(.horizontal, 30)
        }
        .edgesIgnoringSafeArea(.all)
    }
}


#Preview {
    
    @Previewable @StateObject var authVM = AuthViewModel()

    
    LogInView()
        .environmentObject(authVM)
}
