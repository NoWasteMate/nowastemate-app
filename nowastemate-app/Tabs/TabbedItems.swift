//
//  TabbedItems.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 15/11/25.
//


enum TabbedItems: Int, CaseIterable{
    case home = 0
    case content = 1
    
    var title: String{
        switch self {
        case .home:
            return "Home"
            
        case .content:
            return "Content"
        }
    }
    
    var systemIcon: String{
        switch self {
        case .home:
            return "house.fill"
        case .content:
            return "doc.text"
        }
    }
}
