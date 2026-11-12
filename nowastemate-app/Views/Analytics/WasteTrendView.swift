//
//  WasteTrendView.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2026-10-11.
//

// References:
// https://developer.apple.com/documentation/charts/barmark
// https://developer.apple.com/documentation/swiftui/contentunavailableview
// on charts
// https://www.youtube.com/watch?v=mnH7YRmuVKw

import SwiftUI
import Charts

struct WasteTrendView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var analyticsVM: AnalyticsViewModel
    
    // setting the button for personal and family
    var showsFamily = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Period", selection: $analyticsVM.selectedPeriod) {
                    ForEach(TrendPeriod.allCases) { period in
                        Text(period.displayName).tag(period)
                    }
                }
                .pickerStyle(.segmented)

                content

                Spacer()
            }
            .padding(16)
        }
        .task { load() }
        .onChange(of: analyticsVM.selectedPeriod) { load() }
        .onChange(of: showsFamily) { load() }
    }

    @ViewBuilder
    private var content: some View {
        if analyticsVM.isLoading && analyticsVM.wasteTrend == nil {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .frame(maxWidth: .infinity, minHeight: 260)
        } else if let message = analyticsVM.errorMessage {
            ContentUnavailableView {
                Label("Couldn't load waste trend", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Try again") { load() }
            }
        } else if let trend = analyticsVM.wasteTrend, trend.hasData {
            chart(for: trend)
        } else if analyticsVM.wasteTrend != nil {
            ContentUnavailableView(
                showsFamily ? "No wasted items in your family yet" :
                "No wasted items yet",
                systemImage: "leaf",
                description: Text(showsFamily ? "Items in your family marks as wasted will show up here." : "Items you mark as wasted will show up here.")
            )
        }
    }

    private func chart(for trend: WasteTrend) -> some View {
        let unit = trend.period == .week ? "weeks" : "months"
        
        return VStack(alignment: .leading, spacing: 8) {
            Text(showsFamily ? "Your family wasted \(trend.totalWasted) items in the last \(analyticsVM.periods) \(unit)" : "\(trend.totalWasted) items wasted in the last \(analyticsVM.periods) \(unit)")
                    .font(.headline)
                    .foregroundStyle(.white)

            Chart {
                ForEach(trend.buckets) { bucket in
                    ForEach(bucket.segments, id: \.label) { segment in
                        BarMark(
                            x: .value("Period", label(for: bucket, period: trend.period)),
                            y: .value("Wasted", segment.count)
                        )
                        .foregroundStyle(by: .value("Reason", segment.label))
                    }
                }
            }
            // Fixed domain so empty weeks/months still get a slot on the axis (no gaps)
            .chartXScale(domain: trend.buckets.map { label(for: $0, period: trend.period) })
            .chartLegend(position: .bottom)
            .frame(height: 260)
        }
        .padding()
        .glassEffect(.clear, in: .rect(cornerRadius: 6))
    }

    // "Oct 5" for weeks, "Oct" for months
    private func label(for bucket: WasteTrendInformation, period: TrendPeriod) -> String {
        period == .week
            ? bucket.periodStart.formatted(.dateTime.month(.abbreviated).day())
            : bucket.periodStart.formatted(.dateTime.month(.abbreviated))
    }

    private func load() {
        guard let user = authVM.user else { return }
        analyticsVM.userWasteOvertime(for: user, period: analyticsVM.selectedPeriod, family: showsFamily)
    }
}

#if DEBUG
#Preview(traits: .appEnvironment) {
    NavigationStack {
        WasteTrendView()
    }
}
#endif
