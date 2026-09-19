//
//  FamilyMemberView.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 06/12/2025.
//

import SwiftUI

struct FamilyMemberView: View {
    
    @EnvironmentObject var familyVM: FamilyViewModel
    
    @State private var editNameAlert: Bool = false
    
    @State private var newName: String = ""
    
    var validName: Bool {
        !newName.isEmpty
    }

    
    var body: some View {

        ZStack {
            
            //https://medium.com/push-2-prod/gradients-in-swiftui-e3481685cb9d
            //making it span entire screen
            LinearGradient(gradient: Gradient(colors: [.familyViewLightGradient,.familyViewDarkGradient]), startPoint: .top, endPoint: .bottom)

            VStack(alignment: .leading, spacing: 24) {

                //title
                Text("Your Family")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom)

                if familyVM.family != nil && familyVM.familyMembers != nil {
                
                    VStack(spacing: 8) {
                        
                        HStack (spacing: 4) {
                            
                            Text(familyVM.family?.title ?? "")
                                .font(.title).bold()
                                .foregroundColor(.white)
                            
                            if (familyVM.isOwner){
                                Button {
                                    editNameAlert = true
                                }
                                label: {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.white)
                                        .imageScale(.small).bold()
                                }
                                .alert("Change Family Name", isPresented: $editNameAlert, actions: {
                                        TextField("", text: $newName)
                                        
                                        Button("Cancel", role: .cancel) {
                                            //simply dismiss here
                                        }
                                        
                                        Button("Confirm", role: .confirm) {
                                            
                                            familyVM.editFamilyName(title: newName)
                                            
                                        }
                                    
                                    
                                        }, message: {
                                            Text("Please enter the new desired family name")
                                        })
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        
                        
                        
                        
                        
                        //https://medium.com/@jpmtech/swiftui-list-from-beginner-to-merlin-5308261b78b6
                        //https://sarunw.com/posts/swiftui-list-with-foreach/
                        ForEach(familyVM.familyMembers!, id: \.self) { item in
                            Button(item){}
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(.black, lineWidth: 1)
                                )
                                .padding(.horizontal, 12)
                            }
                        }
                    }
                        
                    else if let errorMessage = familyVM.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    } else {
                        Text("Loading Your Family")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color.white.opacity(0.2))
                        .padding(.horizontal, 12)
                )
            
                
        }
        .onAppear {
            familyVM.findFamilyMembers()
            familyVM.findExistingFamily()
        }
        .edgesIgnoringSafeArea(.all)

    }
}


#if DEBUG
#Preview(traits: .appEnvironment) {
    FamilyMemberView()
}
#endif
