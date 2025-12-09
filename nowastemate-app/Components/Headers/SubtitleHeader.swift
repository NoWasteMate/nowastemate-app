//
//  SubtitleHeader.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 17/11/25.
//

import SwiftUI

struct SubtitleHeader: View {
    let subtitleText: String
    var body: some View {
        Text(subtitleText)
            .font(.title.bold())
            .foregroundStyle(.white)
    
    }
}
