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
    
    @State private var isOn = false

    var body: some View {
        VStack{
                    ForEach(DietaryRestrictions.allCases) { choice in
                        HStack {
                            Toggle(isOn: $isOn) {
                                Text(choice.rawValue)
                                    }
                            .toggleStyle(.automatic)
                        }
                    }
                }    }
}

#Preview {
    DietaryRestrictionsView()
}
