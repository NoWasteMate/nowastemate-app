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
    
    @Published var productUsage: ProductUsage?
    @Published var selectedUsageWindow: Int? = 30
    @Published var isLoadingUsage = false
    @Published var usageErrorMessage: String?
    
    @Published var categoryWasteResults: [String: Double]?
    
    // tracking to see each request if it is older then that gets ignored
    private var usageRequestId = 0
    
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
    
    func productUsageOverview(for user: User, days: Int?) {
        loadProductUsage(days : days) { completion in
            self.service.getProductUsageOverview(user: user, days: days, completionHandler: completion)
        }
    }
    
    func loadProductUsage(days : Int?, fetch: (@escaping (Result<ProductUsage, Error>) -> Void) -> Void) {
        usageRequestId += 1
        let requestId = usageRequestId
        
        // clearing the old chart so new window never labels previous window's data
        productUsage = nil
        usageErrorMessage = nil
        isLoadingUsage = true
        
        fetch { result in
            guard requestId == self.usageRequestId else { return }
            self.isLoadingUsage = false
            
            switch result {
            case .success(let usage):
                self.productUsage = usage
            case.failure(let error):
                self.usageErrorMessage = error.localizedDescription
            }
        }
    }
    
    // clear it like ProductViewModel.resetProducts()
    func resetAnalytics() {
        wasteTrend = nil
        selectedPeriod = .week
        isLoading = false
        errorMessage = nil
        usageRequestId += 1
        productUsage = nil
        selectedUsageWindow = 30
        isLoadingUsage = false
        usageErrorMessage = nil
    }
    
    func categoryWaste(for user: User, familyId: String?) {
        
        service.getCategoryWaste(user: user, familyId: familyId) { result in
            switch result {
            case .success(let wasteStats):
                
                DispatchQueue.main.async {
                    self.categoryWasteResults = wasteStats
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
}
