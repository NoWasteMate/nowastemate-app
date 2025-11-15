//
//  SignUpView.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 15/11/2025.
//

import SwiftUI

struct SignUpView: View {
    
    //state variables for user input
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""

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
                    
                    Text("First Name")
                        .font(.headline)
                        .foregroundColor(Color.brown)

                    TextField("", text: $firstName)
                        .padding()
                        .background(Color.white)
                        .border(Color.gray)
                        .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(.gray, lineWidth: 2)
                        )
                    
                    Text("Last Name")
                        .font(.headline)
                        .foregroundColor(Color.brown)

                    TextField("", text: $lastName)
                        .padding()
                        .background(Color.white)
                        .border(Color.gray)
                        .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(.gray, lineWidth: 2)
                        )
                    
                    Text("Email")
                        .font(.headline)
                        .foregroundColor(Color.brown)

                    TextField("", text: $email)
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

                    TextField("", text: $email)
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

                    Button(action: {}) {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(30)
                    }
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
