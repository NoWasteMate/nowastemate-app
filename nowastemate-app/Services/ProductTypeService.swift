//
//  ProductTypeService.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 8/10/26.
//

import Foundation
import FirebaseAuth

// Keeps a saved copy of GET /productTypes so suggestions work before the request finishes
struct ProductTypeService {
    static let shared = ProductTypeService()

    // Caches can be cleared by iOS, which is fine since the list just downloads again
    // https://www.hackingwithswift.com/books/ios-swiftui/writing-data-to-the-documents-directory
    // https://www.swiftbysundell.com/articles/caching-in-swift/
    private let fileURL = URL.cachesDirectory.appending(path: "productTypes.json")

    // nil on first launch, before anything has been saved
    func loadSavedList() -> ProductTypeList? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(ProductTypeList.self, from: data)
    }

    private func saveList(_ data: Data) {
        try? data.write(to: fileURL, options: [.atomic])
    }
    
    // Sends the saved version so the backend can answer upToDate instead of the whole list
    func fetchProductTypes(user: User, version: Int?, completionHandler: @escaping (Result<ProductTypeList, Error>) -> Void) {
        user.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                DispatchQueue.main.async { completionHandler(.failure(error)) }
                return
            }

            var urlString = "\(AppConfig.baseUrl)/productTypes"
            if let version {
                urlString += "?version=\(version)"
            }
            var request = URLRequest(url: URL(string: urlString)!)
            request.httpMethod = "GET"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")

            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        completionHandler(.failure(error ?? URLError(.badServerResponse)))
                    }
                    return
                }
                do {
                    let list = try JSONDecoder().decode(ProductTypeList.self, from: data)
                    // Only a full list replaces the saved one, not an upToDate reply
                    if list.types != nil {
                        saveList(data)
                    }
                    DispatchQueue.main.async { completionHandler(.success(list)) }
                } catch {
                    print(error)
                    DispatchQueue.main.async { completionHandler(.failure(error)) }
                }
            }
            task.resume()
        }
    }
}
