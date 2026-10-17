//
//  CategoryWasteView.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 16/10/2026.
//



import SwiftUI

struct CategoryWasteView: View {
    
    
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var analyticsVM: AnalyticsViewModel
    

    var body: some View {
        ZStack {
            
            //https://medium.com/push-2-prod/gradients-in-swiftui-e3481685cb9d
            //making it span entire screen
            LinearGradient(gradient: Gradient(colors: [.familyViewLightGradient,.familyViewDarkGradient]), startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 24) {
                
            }
            .padding(.horizontal, 30)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#if DEBUG
#Preview(traits: .appEnvironment) {
    CategoryWasteView()
}
#endif
