//
//  CustomTabBarView.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 15/11/25.
//
//https://developer.apple.com/documentation/SwiftUI/TabView

import SwiftUI

struct CustomTabBarView: View {
    
    @State var selectedTab = 0

    var body: some View {
        
        ZStack(alignment: .bottom){
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)

                ContentView()
                    .tag(1)
            }.tabViewStyle(.page(indexDisplayMode: .never))
            
            
            HStack{
                ForEach((TabbedItems.allCases), id: \.self){ item in
                    Button{
                        selectedTab = item.rawValue
                    } label: {
                        CustomTabItem(systemIcon: item.systemIcon, title: item.title, isActive: (selectedTab == item.rawValue))
                    }
                }
            }
        }
    }
}

extension CustomTabBarView {
    func CustomTabItem(imageName: String? = nil, systemIcon: String? = nil, title: String, isActive: Bool) -> some View{
        HStack(spacing: 10){
            Spacer()
            
            // Added optional functionality to allow for custom images and system icons. Allows for customization of toolbar icons.
            if let imageName
            {
                Image(imageName)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(isActive ? .black : .gray)
                    .frame(width: 20, height: 20)
            }
            else if let systemIcon
            {
                Image(systemName: systemIcon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isActive ? .black : .gray)
            }
            
            
            if isActive{
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .black : .gray)
            }
            Spacer()
        }
      

    }
}

#Preview {
    CustomTabBarView()
}
