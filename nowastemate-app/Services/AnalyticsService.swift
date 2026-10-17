//
//  AnalyticsService.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2026-10-11.
//

// References:
// https://gurjit-singh.medium.com/how-to-use-completion-handler-in-swift-d1c26b30c67
// https://developer.apple.com/documentation/dispatch/dispatchqueue/main
// https://firebase.google.com/docs/auth/admin/verify-id-tokens
// https://developer.apple.com/documentation/foundation/url/appendingpathcomponent(_:)
// https://developer.apple.com/documentation/foundation/urlcomponents
// https://developer.apple.com/documentation/foundation/urlqueryitem
// https://developer.apple.com/documentation/foundation/httpurlresponse/statuscode
// https://developer.apple.com/documentation/foundation/jsondecoder/datedecodingstrategy
// https://developer.apple.com/documentation/foundation/localizederror
// https://developer.apple.com/videos/play/wwdc2020/10149/

import Foundation
import FirebaseAuth

enum AnalyticsError: LocalizedError {
    case unauthorized
    case failed
    
    var errorDescription: String? {
        switch self {
        case .unauthorized: return "Please sign in again"
        case .failed: return "Couldn't load your analytics, try again"
        }
    }
}

// Protocol lets previews inject sample data instead of calling backend
protocol AnalyticsServiceProtocol {
    func getUserWasteOvertime(user: User, period: TrendPeriod, periods: Int, completionHandler: @escaping (Result<WasteTrend, Error>) -> Void)
    
    func getProductUsageOverview(user: User, days: Int?, completionHandler: @escaping (Result<ProductUsage, Error>) -> Void)
}

struct AnalyticsService: AnalyticsServiceProtocol {
    static let shared = AnalyticsService()
    
    // Get method
    func getUserWasteOvertime(user: User, period: TrendPeriod, periods: Int, completionHandler: @escaping (Result<WasteTrend, Error>) -> Void) {
        user.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print(error)
                DispatchQueue.main.async { completionHandler(.failure(error)) }
                return
            }
            
            // URLComponents builds the query string instead of hand-interpolating it
            var components = URLComponents(url: AppConfig.baseUrl.appendingPathComponent("analytics/wasteTrend"), resolvingAgainstBaseURL: false)
            components?.queryItems = [
                URLQueryItem(name: "period", value: period.rawValue),
                URLQueryItem(name: "periods", value: String(periods))
            ]
            guard let url = components?.url else {
                DispatchQueue.main.async { completionHandler(.failure(URLError(.badURL))) }
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        completionHandler(.failure(error ?? URLError(.badServerResponse)))
                    }
                    return
                }
                
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                guard statusCode == 200 else {
                    print("getUserWasteOvertime failed: \(statusCode)")
                    let failure: AnalyticsError = (statusCode == 401 || statusCode == 403) ? .unauthorized : .failed
                    DispatchQueue.main.async { completionHandler(.failure(failure)) }
                    return
                }
                
                do {
                    // Backend sends periodStart with an offset, e.g. 2026-10-05T00:00:00-04:00
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let trend = try decoder.decode(WasteTrend.self, from: data)
                    DispatchQueue.main.async { completionHandler(.success(trend)) }
                } catch {
                    // Pass decode errors on so a bad date shows an error instead of an empty chart
                    print(error)
                    DispatchQueue.main.async { completionHandler(.failure(error)) }
                }
            }
            task.resume()
        }
    }
    
    func getProductUsageOverview(user: User, days: Int?, completionHandler: @escaping (Result<ProductUsage, any Error>) -> Void) {
        user.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print(error)
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
                return
            }
            
            var components = URLComponents(url: AppConfig.baseUrl.appendingPathComponent("analytics/productUsage"), resolvingAgainstBaseURL: false)
            
            if let days = days {
                components?.queryItems = [URLQueryItem(name: "days", value: String(days))]
            }
            
            guard let url = components?.url else {
                DispatchQueue.main.async{
                    completionHandler(.failure(URLError(.badURL)))
                }
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        completionHandler(.failure(error ?? URLError(.badServerResponse)))
                    }
                    return
                }
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                guard statusCode == 200 else {
                    print("getProductUsageOverview failed: \(statusCode)")
                    let failure: AnalyticsError = (statusCode == 401 || statusCode == 403) ? .unauthorized : .failed
                    DispatchQueue.main.async { completionHandler(.failure(failure)) }
                    return
                }
                
                do {
                    let usage = try JSONDecoder().decode(ProductUsage.self, from: data)
                    DispatchQueue.main.async { completionHandler(.success(usage)) }
                } catch {
                    print(error)
                    DispatchQueue.main.async { completionHandler(.failure(error)) }
                }
            }
            task.resume()
        }
    }
    
    func getCategoryWaste(user: User, familyId: String?, completionHandler: @escaping (Result<[CategoryWaste], Error>) -> Void){
        user.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            print(error)
            return;
          }
            
            //declare to be set later
            let url: URL
            
            if let familyId {
                url = URL(string: "\(AppConfig.baseUrl)/analytics/category_waste/?familyId=\(familyId)")!
            } else {
                url = URL(string: "\(AppConfig.baseUrl)/analytics/category_waste")!
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) {data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                do {
                    let wasteStats = try JSONDecoder().decode([CategoryWaste].self, from: data)
                              completionHandler(.success(wasteStats))
                }
                
                catch {
                    print(error)
                    completionHandler(.failure(error))
                }
            }
            task.resume()

        }
        
    }
    
}
