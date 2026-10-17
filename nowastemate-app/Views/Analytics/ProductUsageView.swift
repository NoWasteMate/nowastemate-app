//
//  ProductUsageView.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2026-10-16.
//

// References:
// https://developer.apple.com/documentation/charts/sectormark
// https://developer.apple.com/documentation/charts/chart/chartbackground(alignment:content:)
// https://developer.apple.com/documentation/swiftui/contentunavailableview

import SwiftUI
import Charts

struct ProductUsageView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var analyticsVM: AnalyticsViewModel
    
    private let windows: [(label: String, days: Int?)] = [("30 days", 30), ("6 months", 180), ("All time", nil)]
    
    
    var body: some View {
        ZStack {
            // WasteOverviewView does the scrolling now
            VStack {
                VStack(alignment: .leading, spacing: 16) {
                    Picker("Window", selection: $analyticsVM.selectedUsageWindow) {
                        ForEach(windows, id: \.label) { window in
                            Text(window.label).tag(window.days)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    content
                }
                .padding(16)
            }
        }
        .task { load() }
        .onChange(of: analyticsVM.selectedUsageWindow) { load() }
    }

        @ViewBuilder
    private var content: some View {
        if analyticsVM.isLoadingUsage {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .frame(maxWidth: .infinity, minHeight: 260)
        } else if let message = analyticsVM.usageErrorMessage {
            ContentUnavailableView {
                Label("Couldn't load product usage", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Try again") { load() }
            }
        } else if let usage = analyticsVM.productUsage, usage.hasData {
            chart(for: usage)
        } else if analyticsVM.productUsage != nil {
            ContentUnavailableView(
                "Nothing finished \(windowText)",
                systemImage: "chart.pie",
                description: Text("Products you mark as consumed or wasted will show up here.")
            )
        }
    }

    private func chart(for usage: ProductUsage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Chart(usage.slices, id: \.label) { slice in
                SectorMark(angle: .value("Count", slice.count), innerRadius: .ratio(0.6), angularInset: 1.5)
                    .foregroundStyle(by: .value("Outcome", slice.label))
            }
            .chartForegroundStyleScale(["Consumed": Color.green, "Used in recipe": Color.blue, "Wasted": Color.orange])
            .chartLegend(.hidden)
            // Total in the middle of the donut
            .chartBackground { _ in
                VStack {
                    Text("\(usage.total)").font(.title.bold())
                    Text("items").font(.caption)
                }
                .foregroundStyle(.white)
            }
            .frame(height: 240)
            
            // Counts and percentages beside the chart
            ForEach(usage.slices, id: \.label) { slice in
                HStack {
                    Text(slice.label)
                    Spacer()
                    Text("\(slice.count)  ·  \(percent(slice.count, of: usage.total))")
                }
                .foregroundStyle(.white)
            }
            
            if usage.wastedCount > 0 {
                Text("Why it was wasted")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.top, 8)
                ForEach(usage.wasteSegments, id: \.label) { segment in
                    HStack {
                        Text(segment.label)
                        Spacer()
                        Text("\(segment.count)")
                    }
                    .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
        .padding()
        .glassEffect(.clear, in: .rect(cornerRadius: 6))
    }

    private var windowText: String {
        switch analyticsVM.selectedUsageWindow {
        case 30: return "in the last 30 days"
        case 180: return "in the last 6 months"
        default: return "yet"
        }
    }

    private func percent(_ count: Int, of total: Int) -> String {
        (Double(count) / Double(total)).formatted(.percent.precision(.fractionLength(0)))
    }

    private func load() {
        guard let user = authVM.user else { return }
        analyticsVM.productUsageOverview(for: user, days: analyticsVM.selectedUsageWindow)
    }
    
}


#if DEBUG
#Preview(traits: .appEnvironment) {
    NavigationStack {
        ProductUsageView()
    }
}
#endif
