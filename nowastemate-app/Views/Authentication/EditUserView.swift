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
    @State private var notificationDays = 1
    @State private var notificationHour = 9
        
    var isFormValid: Bool {
        !email.isEmpty && !firstName.isEmpty && !lastName.isEmpty
    }
    
    
    //https://stackoverflow.com/questions/37900321/find-whether-two-swift-arrays-contain-the-same-elements
    //compare if anything has changed
    var notNewInput: Bool {
        email == authVM.userInfo?.email && firstName == authVM.userInfo?.firstName && lastName == authVM.userInfo?.lastName && notificationDays == authVM.userInfo?.notificationDays && notificationHour == authVM.userInfo?.notificationHour && Set(authVM.newDietaryRestrictions) == Set(authVM.userInfo?.dietaryRestrictions ?? [])
        
    }
    
    @State private var showAlert = false
    @State private var alertMessage = ""


    @EnvironmentObject var authVM: AuthViewModel
    
    @EnvironmentObject var productVM: ProductViewModel
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            
            //https://medium.com/push-2-prod/gradients-in-swiftui-e3481685cb9d
            //making it span entire screen
            LinearGradient(gradient: Gradient(colors: [.familyViewLightGradient, .familyViewDarkGradient]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView {
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    HStack {
                        
                        NavigationLink {
                            FAQView()
                        }
                        label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(Color.baseText)
                                .imageScale(.small)
                                .padding()
                                .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 30))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topTrailing)
                    
                    
                    //title
                    Text("Update Information")
                    //https://sarunw.com/posts/swiftui-text-font/
                        .font(
                            .largeTitle
                                .weight(.medium)
                        )
                        .foregroundColor(Color.baseText)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .frame(maxWidth: .infinity)
                        .symbolVariant(.circle)
                        .foregroundStyle(Color.baseText)
                    
                    VStack(spacing: 8) {
                        
                        Text("First Name")
                            .font(.headline)
                            .foregroundColor(Color.baseText)
                        
                        TextField("", text: $firstName)
                            .foregroundStyle(Color.baseText)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.baseText, lineWidth: 1)
                            )
                        
                        Text("Last Name")
                            .font(.headline)
                            .foregroundColor(Color.baseText)
                        
                        TextField("", text: $lastName)
                            .foregroundStyle(Color.baseText)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.baseText, lineWidth: 1)
                            )
                        
                        Text("Dietary Restrictions?")
                            .font(.headline)
                            .foregroundColor(Color.baseText)
                        
                        NavigationLink {
                            
                            DietaryRestrictionsView()
                            
                        } label: {
                            
                            HStack {
                                
                                Text(authVM.newDietaryRestrictions != [] ? "Edit Restrictions" : "Set Up Restrictions")
                                
                                Spacer()
                                
                                Image(systemName: "arrow.right")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .symbolVariant(.circle)
                                    .foregroundStyle(Color.baseText)
                            }
                        }
                        .foregroundStyle(Color.baseText)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.baseText, lineWidth: 1)
                        )
                        .tint(.white)
                        
                        Text("Email")
                            .font(.headline)
                            .foregroundColor(Color.baseText)
                            .bold()
                        
                        TextField("", text: $email)
                            .textInputAutocapitalization(.never)
                            .foregroundStyle(Color.baseText)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.baseText, lineWidth: 1)
                            )
                        //https://stackoverflow.com/questions/63332391/set-picker-starting-with-two-digit-numbers-from-00-swiftui
                        //https://wesleydegroot.nl/blog/swiftui-picker
                        //https://developer.apple.com/documentation/swiftui/view/tint(_:)-23xyq
                        
                        Section("Notification Setup") {
                            
                            VStack {
                                
                                HStack {
                                    
                                    Text("Amount of days before expiry")
                                    
                                    Spacer()
                                    
                                    Picker("Day Selection", selection: $notificationDays) {
                                        ForEach(1..<4) { number in
                                            Text(String(number)).tag(number)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(Color.baseText)
                                    
                                }
                                
                                HStack {
                                    
                                    Text("Hour of the day to get notified")
                                    
                                    Spacer()
                                    
                                    Picker("Hour Selection", selection: $notificationHour) {
                                        ForEach(1..<24) { number in
                                            Text(String(number)).tag(number)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(Color.baseText)

                                    
                                    
                                }
                                
                            }.foregroundStyle(Color.baseText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.baseText, lineWidth: 1)
                                )
                            
                        }.foregroundStyle(Color.baseText)
                        
                        
                        
                        
                        Button(!isFormValid || notNewInput ? "Please enter new details" : isFormValid ? "Save and Sign out" : "Please enter new details"){
                            
                            guard isFormValid else {
                                alertMessage = "Please enter your details."
                                showAlert = true
                                return
                            }
                            
                            authVM.editRequest(email: email, firstName: firstName, lastName: lastName, dietaryRestrictions: authVM.newDietaryRestrictions, notificationDays: notificationDays, notificationHour: notificationHour) { error in
                                if let error = error {
                                    alertMessage = error.localizedDescription
                                    showAlert = true
                                    
                                } else {
                                    dismiss()
                                }
                            }
                        }
                        .disabled(!isFormValid || notNewInput)
                        
                        //https://developer.apple.com/documentation/swiftui/alert
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("Incorrect Input"),
                                message: Text(alertMessage)
                            )
                            
                        }
                        .foregroundColor(Color.inverseBaseText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(!isFormValid || notNewInput ? .gray : isFormValid ? .baseText : .gray)
                        .cornerRadius(30)
                        .padding(.top)
                        
                        Button("Logout"){
                            authVM.signOut()
                        }
                        .foregroundColor(Color.baseText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.inverseBaseText)
                        .cornerRadius(30)
                        .padding(.top)
                    }
                    .padding()
                }
                .padding(.horizontal, 30)
            }
            .onAppear {
                email = authVM.userInfo?.email ?? ""
                firstName = authVM.userInfo?.firstName ?? ""
                lastName = authVM.userInfo?.lastName ?? ""
                notificationDays = authVM.userInfo?.notificationDays ?? 1
                notificationHour = authVM.userInfo?.notificationHour ?? 9
            }
        }
    }
}


#if DEBUG
#Preview(traits: .appEnvironment) {
    EditUserView()
}
#endif
