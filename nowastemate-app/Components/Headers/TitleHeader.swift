//
//  TitleHeader.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 17/11/25.
//

import SwiftUI

struct TitleHeader: View {
    let titleText: String
    var body: some View {
        Text(titleText)
            .font(.largeTitle.bold())
            .foregroundStyle(.white)
    }
}
