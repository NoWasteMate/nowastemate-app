//
//  FamilyMemberView.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 06/12/2025.
//

import SwiftUI
import FirebaseAuth

struct FamilyMemberView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var familyVM: FamilyViewModel
    @EnvironmentObject var analyticsVM: AnalyticsViewModel
    
    @State private var editNameAlert: Bool = false
    @State private var manageFamilyAlert: Bool = false
    @State private var confirmTransfer: Bool = false
    @State private var confirmDelete: Bool = false
    @State private var isClicked: Bool = false
    @State private var confirmLeave: Bool = false
    @State private var confirmFamilyDeletion: Bool = false

    
    @State private var clickedMember: FamilyMember = FamilyMember(member: "", email: "")
    
    @State private var newName: String = ""
    
    var validName: Bool {
        !newName.isEmpty
    }

    
    var body: some View {

        ZStack {
            
            //https://medium.com/push-2-prod/gradients-in-swiftui-e3481685cb9d
            //making it span entire screen
            LinearGradient(gradient: Gradient(colors: [.familyViewLightGradient,.familyViewDarkGradient]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            
            VStack(alignment: .leading, spacing: 10) {
                
                HStack {
                    Text("Family Members")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                    
                    Spacer()
                }.padding()
                
                ScrollView  {
                    
                    VStack (alignment: .leading, spacing: 15) {
                        
                        VStack {
                            
                            if familyVM.family != nil && familyVM.familyMembers != nil {
                                
                                VStack(spacing: 8) {
                                    
                                    HStack (spacing: 4) {
                                        
                                        Text(familyVM.family?.title ?? "")
                                            .font(.title)
                                            .foregroundColor(.white)
                                        
                                        if (familyVM.isOwner){
                                            Button {
                                                editNameAlert = true
                                                newName = familyVM.family?.title ?? ""
                                            }
                                            label: {
                                                Image(systemName: "pencil")
                                                    .foregroundColor(.white)
                                                    .imageScale(.small).bold()
                                            }
                                            .alert("Change Family Name", isPresented: $editNameAlert, actions: {
                                                TextField("Enter new Family name", text: $newName)
                                                
                                                
                                                Button("Cancel", role: .cancel) {
                                                    //simply dismiss here
                                                }
                                                
                                                Button("Confirm", role: .confirm) {
                                                    
                                                    if let user = authVM.user {
                                                        familyVM.editFamilyName(for: user, title: newName)
                                                    }
                                                    
                                                }.disabled(!validName || familyVM.family?.title == newName)
                                                
                                                
                                            }, message: {
                                                Text("Please enter the new desired family name")
                                            })
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.bottom)
                                    ScrollView {
                                        //https://medium.com/@jpmtech/swiftui-list-from-beginner-to-merlin-5308261b78b6
                                        //https://sarunw.com/posts/swiftui-list-with-foreach/
                                        //https://www.hackingwithswift.com/books/ios-swiftui/why-does-self-work-for-foreach
                                        ForEach(familyVM.familyMembers!, id: \.self) { item in
                                            HStack {
                                                Button("\(item.firstName!) \(item.lastName!)"){
                                                    clickedMember = item
                                                    manageFamilyAlert = true
                                                }
                                                if item.member == familyVM.family?.ownerId {
                                                    Image(systemName: "star")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 12, height: 12)
                                                        .foregroundStyle(.white)
                                                }
                                            }
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                            .cornerRadius(12)
                                            
                                            .glassEffect(.clear.interactive().tint(Color("CardColor")), in:.rect(cornerRadius: 12))
                                            .padding(.horizontal, 12)
                                            .disabled(!familyVM.isOwner || familyVM.currentUser?.uid == item.member )
                                        }
                                        .alert("Manage Family", isPresented: $manageFamilyAlert, actions: {
                                            Button("Transfer Ownership", role: .confirm) {
                                                confirmTransfer = true
                                            }
                                            
                                            Button("Remove Member", role: .destructive) {
                                                confirmDelete = true
                                            }
                                            
                                            Button("Cancel", role: .cancel) {
                                                //do nothing
                                            }
                                            
                                            
                                        }, message: {
                                            Text("Do you wish to update this member?")
                                        })
                                        .alert("Transfer Family Ownership", isPresented: $confirmTransfer, actions: {
                                            Button("Transfer Ownership", role: .confirm) {
                                                if let user = authVM.user {
                                                    familyVM.transferOwner(for: user, member: clickedMember)
                                                }
                                            }
                                            Button("Cancel", role: .cancel) {
                                                //do nothing
                                            }
                                            
                                        }, message: {
                                            Text("Confirm you intend to transfer ownership to this user - This cannot be undone")
                                        })
                                        .alert("Delete member", isPresented: $confirmDelete, actions: {
                                            Button("Confirm", role: .confirm) {
                                                if let user = authVM.user {
                                                    familyVM.removeFamilyMembership(for: user, member: clickedMember)
                                                }
                                            }
                                            Button("Cancel", role: .cancel) {
                                                //do nothing
                                            }
                                            
                                        }, message: {
                                            Text("Confirm you intend to delete this member - This cannot be undone")
                                        })
                                        
                                        .alert("Remove Family", isPresented: $confirmFamilyDeletion, actions: {
                                            
                                            Button("Yes, I want to delete the Family", role: .destructive) {
                                                if let user = authVM.user {
                                                    familyVM.removeFamily(for: user)
                                                }
                                            }
                                            
                                            Button("Cancel", role: .cancel) {
                                                //do nothing
                                            }
                                            
                                            
                                        }, message: {
                                            Text("Please confirm you want to delete the family - This cannot be undone.")
                                        })
                                        
                                        .alert("Leave Family", isPresented: $confirmLeave, actions: {
                                            
                                            Button("Yes, I want to leave the Family", role: .destructive) {
                                                if let user = authVM.user {
                                                    familyVM.leaveFamily(for: user, member: FamilyMember(member: user.uid, email: user.email))
                                                }
                                            }
                                            
                                            Button("Cancel", role: .cancel) {
                                                //do nothing
                                            }
                                            
                                            
                                        }, message: {
                                            Text("Please confirm you want to leave the family - This cannot be undone.")
                                        })
                                    }
                                    
                                    
                                }
                                
                            }
                            
                            else if let errorMessage = familyVM.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                            } else {
                                ProgressView().tint(.white)
                            }
                            
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.white.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(.white, lineWidth: 2)
                        )
                        .frame(height: UIScreen.main.bounds.height * 0.4)                             //https://stackoverflow.com/questions/61160039/swiftui-trying-to-keep-the-fullscreen-size-of-a-view-in-a-scrollview
                        
                        
                        VStack {
                            
                            
                            HStack {
                                NavigationLink {
                                    LeaderboardView()
                                }
                                label: {
                                    
                                    Text("Check Out The Family Leaderboard").foregroundStyle(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.right")
                                        .foregroundColor(.white)
                                        .imageScale(.small)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.white, lineWidth: 2)
                            )
                            
                            Text("Add Family Members with This Code:")
                            //https://sarunw.com/posts/swiftui-text-font/
                                .font(.subheadline)
                                .bold()
                                .padding(.top, 20)
                                .foregroundColor(.white)
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
                                    ProgressView().tint(.white)
                                }
                                
                                Spacer()
 
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
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.white, lineWidth: 2)
                            )
                            
                            
                            //https://www.devfright.com/how-to-add-tap-to-copy-with-uipasteboard-in-swiftui/
                            if isClicked {
                                Text("Copied!")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.white, lineWidth: 2)
                                    )
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                
                            }
                            
                        }
                        
                        if !familyVM.isOwner {
                            VStack {
                                Button("Leave Family"){
                                    confirmLeave = true
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 24)
                                .background(.white)
                                .cornerRadius(30)
                            }
                        }
                        
                        if familyVM.isOwner && familyVM.familyMembers?.count == 1 {
                            VStack {
                                
                                Text("Wish to join someone else's Family instead?")
                                    .foregroundStyle(Color.white)
                                
                                
                                Button("Remove Family"){
                                    confirmFamilyDeletion = true
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 24)
                                .background(.white)
                                .cornerRadius(30)
                            }
                        }
                    }
                }
                
            }.padding(20)
            
        }
        .onAppear {
            isClicked = false
            if let user = authVM.user {
                analyticsVM.familyLeaderboard(for: user)
            }
        }

    }
}

#if DEBUG
#Preview(traits: .appEnvironment) {
    FamilyMemberView()
}
#endif
