//
//  FAQView.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 31/10/2026.
//

import SwiftUI

struct FAQView: View {
    
    
    var body: some View {
        ZStack {
            
            //https://medium.com/push-2-prod/gradients-in-swiftui-e3481685cb9d
            //making it span entire screen
            LinearGradient(gradient: Gradient(colors: [.editUserDarkGradient, .editUserLightGradient]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    //https://www.hackingwithswift.com/quick-start/swiftui/how-to-hide-and-reveal-content-using-disclosuregroup
                    VStack {
                        //title
                        Text("Our FAQ")
                        //https://sarunw.com/posts/swiftui-text-font/
                            .font(
                                .largeTitle
                                    .weight(.medium)
                            )
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .top)
                            .padding()
                        
                        Image(systemName: "info")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .frame(maxWidth: .infinity)
                            .symbolVariant(.circle)
                            .foregroundStyle(.white)
                    }
                    .padding(.vertical, 40)
                    
                    
                    VStack(spacing: 25) {
                        
                        DisclosureGroup("What is NoWasteMate?") {
                            Text("NoWasteMate was developed with the objective of helping every-day users manage groceries alongside their family, in an effort to reduce food waste")
                                .padding()
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.2)))
                        .foregroundStyle(.white)
                        
                        DisclosureGroup("How do I add Products?") {
                            Text("Products can be added manually. Additionally, produce can be added using the camera to quickly classify them, and products with barcodes can be scanned and have their information retrieved.")
                                .padding()
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.2)))
                        .foregroundStyle(.white)
                        
                        DisclosureGroup("How can you help me use groceries?") {
                            Text("Head to the recipe section of the app, which can help come up with ideas for recipes, using the specific products available to you.")
                                .padding()
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.2)))
                        .foregroundStyle(.white)
                        
                        DisclosureGroup("Do products have reminders?") {
                            Text("Yes! From the profile screen, you will be able to configure when you would like to be reminded of the product expiring.")
                                .padding()
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.2)))
                        .foregroundStyle(.white)
                        
                        DisclosureGroup("How do I collaborate with others?") {
                            Text("Head to the Family section in the app, here you add invite other family members, and have products available for everyone, once you are within the same family!")
                                .padding()
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.2)))
                        .foregroundStyle(.white)
                        
                        DisclosureGroup("What is Waste Score?") {
                            Text("A waste score is a calculated total, considering various factors around your consumption and waste, to provide an overall score of your waste")
                                .padding()
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.2)))
                        .foregroundStyle(.white)
                        
                        DisclosureGroup("How can I change my details?") {
                            Text("Click the profile icon from the home screen, here you edit your name, email and dietary restrictions")
                                .padding()
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.2)))
                        .foregroundStyle(.white)
                        
                        DisclosureGroup("Is there an overview of my waste?") {
                            Text("Yes, head to the analytics section, where we provide various stats over both usage and waste!")
                                .padding()
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.2)))
                        .foregroundStyle(.white)
                        
                    }
                    
                    
                }
                .padding(.horizontal, 30)
            }
        }
    }
}


#if DEBUG
#Preview(traits: .appEnvironment) {
    FAQView()
}
#endif

