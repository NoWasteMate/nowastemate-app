//
//  DietaryRestrictionsView.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 08/11/2026.
//

//references
//https://www.reddit.com/r/SwiftUI/comments/1c7humg/view_to_display_all_cases_of_an_enum/
//https://sarunw.com/posts/swiftui-checkbox/


import SwiftUI

struct DietaryRestrictionsView: View {
        
    @State var restrictions: Set<DietaryRestrictions> = []

    var body: some View {
        VStack{
                    ForEach(DietaryRestrictions.allCases) { choice in
                        HStack {
                            Text(choice.rawValue)
                            
                            Button {
                                
                                if (restrictions.contains(choice)) {
                                    restrictions.remove(choice)
                                } else {
                                    restrictions.insert(choice)
                                }
                                                        
                                
                            } label: {
                                Image(systemName: restrictions.contains(choice) ? "checkmark.circle" : "circle")
                                    .foregroundColor(.black)
                                    .imageScale(.small)
                            }.foregroundStyle(restrictions.contains(choice) ? .blue : .black)
                        }
                    }
                }    }
}

#Preview {
    DietaryRestrictionsView()
}
