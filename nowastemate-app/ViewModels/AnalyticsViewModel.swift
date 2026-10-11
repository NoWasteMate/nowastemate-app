//
//  AnalyticsViewModel.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2026-10-11.
//

// references: https://developer.apple.com/documentation/combine/published

import Foundation
import FirebaseAuth
import Combine

class AnalyticsViewModel: ObservableObject {
    @Published var wasteTrend: WasteTrend?
    @Published var selectedPeriod: TrendPeriod = .week
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // 6 weeks / 6 months
    let periods = 6
    
    private let service : AnalyticsServiceProtocol
    
    init(service: AnalyticsServiceProtocol = AnalyticsService.shared) {
        self.service = service
    }
    
    func userWasteOvertime(for user: User, period: TrendPeriod) {
        isLoading = true
        errorMessage = nil
        
        service.getUserWasteOvertime(user: user, period: period, periods: periods) { result in
            guard period == self.selectedPeriod else { return }
            self.isLoading = false
            
            switch result {
            case .success(let trend):
                self.wasteTrend = trend
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // clear it like ProductViewModel.resetProducts()
    func resetAnalytics() {
        wasteTrend = nil
        selectedPeriod = .week
        isLoading = false
        errorMessage = nil
    }
    
}
