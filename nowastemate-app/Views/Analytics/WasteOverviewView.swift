//
//  WasteOverviewView.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 2026-10-16.
//

import SwiftUI

// Waste Score with the trend and usage charts. Opened from the Home score circle
struct WasteOverviewView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var analyticsVM: AnalyticsViewModel

    @State private var selectedTab: WasteOverviewTab = .waste
    @State private var showsFamily = false

    // Gap between the score, its parts and the chart
    private let sectionSpacing: CGFloat = 28
    // Without a minimum height the trend chart collapses inside the ScrollView
    private let trendMinHeight: CGFloat = 440

    // showsFamily can stay on after the family score goes away
    private var isShowingFamily: Bool {
        showsFamily && analyticsVM.wasteScore?.family != nil
    }

    private var shownScore: WasteScore? {
        guard let summary = analyticsVM.wasteScore else { return nil }
        if isShowingFamily, let family = summary.family {
            return family
        }
        return summary.user
    }

    private var backgroundTint: Color {
        guard let rating = shownScore?.rating else { return Color("EditUserDarkGradient") }
        return Color(rating.colorName)
    }

    private var scoreText: String {
        guard let score = shownScore?.score else { return "—" }
        return "\(score)"
    }

    private var productsNeededText: String {
        let productsNeeded = shownScore?.productsNeeded ?? 0
        let noun = productsNeeded == 1 ? "product" : "products"
        return "Mark \(productsNeeded) more \(noun) to get your score"
    }

    // Easier to read than two raw numbers
    private var averageComparisonText: String? {
        guard let score = shownScore?.score, let averageScore = shownScore?.averageScore else { return nil }

        let group = isShowingFamily ? "family" : "user"
        let difference = score - averageScore
        if difference > 0 {
            return "\(difference) above the average \(group) (\(averageScore)pts)"
        } else if difference < 0 {
            return "\(-difference) below the average \(group) (\(averageScore)pts)"
        }
        return "Same as the average \(group) (\(averageScore)pts)"
    }

    private var wastedText: String {
        let wasteRate = shownScore?.wasteRate ?? 0
        let percent = Int((wasteRate * 100).rounded())
        if isShowingFamily {
            return "Your family wastes \(percent)% of its food"
        }
        return "You waste \(percent)% of your food"
    }

    private var averageWastedText: String? {
        guard let averageWasteRate = shownScore?.averageWasteRate else { return nil }

        let percent = Int((averageWasteRate * 100).rounded())
        let group = isShowingFamily ? "family" : "user"
        return "Average \(group): \(percent)%"
    }

    // Same scale as the score: a full bar is twice the average
    private var wastedBarValue: Double {
        guard let wasteRate = shownScore?.wasteRate else { return 0 }
        guard let averageWasteRate = shownScore?.averageWasteRate, averageWasteRate > 0 else { return 0 }

        let barMax = 2 * averageWasteRate
        return min(wasteRate / barMax, 1)
    }

    private var preventableText: String {
        let wasted = shownScore?.wasted ?? 0
        let avoidableWasted = shownScore?.avoidableWasted ?? 0
        if wasted == 0 {
            return "Nothing wasted yet"
        }
        let noun = wasted == 1 ? "item was" : "items were"
        return "\(avoidableWasted) of \(wasted) wasted \(noun) preventable"
    }

    private var preventableBarValue: Double {
        let wasted = shownScore?.wasted ?? 0
        let avoidableWasted = shownScore?.avoidableWasted ?? 0
        guard wasted > 0 else { return 0 }
        return Double(avoidableWasted) / Double(wasted)
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [backgroundTint, Color("EditUserLightGradient")]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack {
                    switch selectedTab {
                    case .waste:
                        wasteTab
                    case .usage:
                        ProductUsageView()
                    }
                }
                .padding(.vertical, 16)
            }
            // Picker shares the nav bar's scroll edge blur
            // https://developer.apple.com/forums/thread/795159
            // https://developer.apple.com/documentation/swiftui/view/safeareabar(edge:alignment:spacing:content:)
            .safeAreaBar(edge: .top) { tabPicker }
            .safeAreaInset(edge: .bottom) {
                if selectedTab == .waste && analyticsVM.wasteScore?.family != nil {
                    familyToggleButton
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
            }
        }
        .navigationTitle("Waste Overview")
        // Large title tried first. On iOS 26 it scrolls under the picker bar
        .navigationBarTitleDisplayMode(.inline)
        .task { load() }
    }

    private var tabPicker: some View {
        Picker("Overview", selection: $selectedTab) {
            ForEach(WasteOverviewTab.allCases) { tab in
                Text(tab.rawValue.capitalized).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private var wasteTab: some View {
        VStack(alignment: .leading, spacing: sectionSpacing) {
            scoreBlock
                .padding(.horizontal, 16)

            // TODO: show the family trend once the backend has one
            WasteTrendView()
                .frame(minHeight: trendMinHeight)
            
            if (isShowingFamily){
                Top3CategoryWaste(isShowingFamily: true)
            } else {
                Top3CategoryWaste(isShowingFamily: false)
            }
        }
    }

    // Icon shows whose score is on screen
    private var familyToggleButton: some View {
        Button {
            showsFamily.toggle()
        } label: {
            Image(systemName: isShowingFamily ? "person.2" : "person")
                .font(.title3)
                .fontWeight(.semibold)
                .frame(width: 28, height: 28)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .controlSize(.large)
    }

    private var scoreBlock: some View {
        VStack(alignment: .leading, spacing: sectionSpacing) {
            if let shownScore {
                scoreHeader

                if shownScore.productsNeeded == 0 {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What makes up your score")
                            .font(.headline)
                        WasteFactRow(title: wastedText, detail: averageWastedText, value: wastedBarValue, showsAverageMark: true)
                        WasteFactRow(title: preventableText, detail: "Expired, forgotten, overbought or stored wrong", value: preventableBarValue)
                    }
                }
            } else if let message = analyticsVM.scoreErrorMessage {
                Text(message)
                    .font(.subheadline)
                Button("Try again") { load() }
                    .buttonStyle(.glass)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // Tight spacing groups the score, band and average
    private var scoreHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            // firstTextBaseline lines the small "pts" up with the bottom of the big number
            // https://www.hackingwithswift.com/books/ios-swiftui/alignment-and-alignment-guides
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(scoreText)
                    .font(.system(size: 64, weight: .bold))
                if shownScore?.score != nil {
                    Text("pts")
                        .font(.title3)
                }
            }

            if let productsNeeded = shownScore?.productsNeeded, productsNeeded > 0 {
                Text(productsNeededText)
                    .font(.subheadline)
            } else {
                Text(shownScore?.rating?.displayName ?? "")
                    .font(.title3.bold())

                if let averageComparisonText {
                    Text(averageComparisonText)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
    }

    private func load() {
        guard let user = authVM.user else { return }
        analyticsVM.loadWasteScore(for: user)
    }
}

private enum WasteOverviewTab: String, CaseIterable, Identifiable {
    case waste
    case usage

    var id: String { rawValue }
}

// A shorter bar is always better
private struct WasteFactRow: View {
    var title: String
    var detail: String? = nil
    var value: Double
    var showsAverageMark = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
            ProgressView(value: value)
                .tint(.white)
                .overlay {
                    // The average sits halfway along the bar
                    if showsAverageMark {
                        Rectangle()
                            .frame(width: 2, height: 10)
                    }
                }
            if let detail {
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
}

private struct Top3CategoryWaste: View {

    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var analyticsVM: AnalyticsViewModel
    @EnvironmentObject var familyVM: FamilyViewModel
    
    @State var isShowingFamily: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            Section {
                VStack {
                    
                    Text("Top 3 Wasted Categories")
                    //https://sarunw.com/posts/swiftui-text-font/
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                    
                    
                    //https://www.hackingwithswift.com/forums/swiftui/swiftui-foreach-iterating-over-an-array-of-key-value-pairs/21069
                    //https://stackoverflow.com/questions/57254547/limit-element-in-foreach-in-swift-ui
                    if let categories = analyticsVM.categoryWasteResults?.sorted(by: {$0.value > $1.value}) {
                        ForEach(categories.prefix(3), id: \.key) { key, value in
                            HStack {
                                Text(key.capitalized).foregroundStyle(Color.white)
                                
                                Spacer()
                                //https://www.reddit.com/r/SwiftUI/comments/wbl7vh/double_in_text_with_1_decimal/
                                //https://www.swiftbysundell.com/articles/formatting-numbers-in-swift/
                                let str = String(format: "%.1f", value)
                                
                                HStack {
                                    Text("\(str)%").foregroundStyle(Color.white)
                                }
                                
                                
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .glassEffect(.clear, in: .rect(cornerRadius: 10))                  .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.white, lineWidth: 1)
                            )
                            .padding(.horizontal, 12)
                        }
                    } else if let message = analyticsVM.categoryWasteErrorMessage {
                        Text(message)
                            .foregroundStyle(Color.white)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 164)
                
                
            }
            
        }
        .padding(.horizontal, 30)
        .onAppear{
            guard let user = authVM.user else { return }
            
            if(isShowingFamily){
                analyticsVM.categoryWaste(for: user, familyId: familyVM.familyId)
            } else {
                analyticsVM.categoryWaste(for: user, familyId: nil)
            }
        }
    }
    
}

#if DEBUG
#Preview(traits: .appEnvironment) {
    NavigationStack {
        WasteOverviewView()
    }
}
#endif
