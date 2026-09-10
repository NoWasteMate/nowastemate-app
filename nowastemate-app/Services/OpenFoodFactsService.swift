//
//  OpenFoodFactsService.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2026-09-10.
//

import Foundation

// references:
// https://openfoodfacts.github.io/documentation/docs/Product-Opener/api/
// https://openfoodfacts.github.io/openfoodfacts-server/api/ref-v2/
// https://developer.apple.com/documentation/swift/decodable
// https://developer.apple.com/documentation/foundation/urlsession/datatask(with:completionhandler:)-52wk8


struct OpenFoodFactsService {
    static let shared = OpenFoodFactsService()
    
    private let baseUrl = URL(string: "https://world.openfoodfacts.org/api/v2/product")!
    
    // fall back error
    enum FallBackerror: Error {
        case notFound
    }
    
    // the response fields
    // Had to be changed to nonisolated because of this warning:
    // Main actor-isolated conformance of 'OpenFoodFactsService.OpenFoodFactsResponse' to 'Decodable' cannot be used in nonisolated context; this is an error in the Swift 6 language mode
    // used https://stackoverflow.com/questions/79795184/in-swift-how-to-resolve-warning-about-main-actor-isolated-conformance-cannot-be to change the two structs to nonisolated to resolve the issue
    nonisolated struct OpenFoodFactsResponse: Decodable {
        let status: Int
        let product: OpenFoodFactsProduct?
    }

    nonisolated struct OpenFoodFactsProduct: Decodable {
        let code: String?
        let product_name: String?
        let categories_tags: [String]?
    }
    
    //@TODO GET method functionality
    func getBarcodeDetails(barcode: String, completion: @escaping (Result<Product, Error>) -> Void) {
        
        let url = URL(string: "\(baseUrl)/\(barcode).json")!
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            //@TODO need to put what happens (error checking)
            
            // if the API returns error
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }
            do {
                let response = try JSONDecoder().decode(OpenFoodFactsResponse.self, from: data)
                
                guard response.status == 1, let offProduct = response.product else {
                    DispatchQueue.main.async {
                        completion(.failure(FallBackerror.notFound))
                    }
                    return
                }
                
                let name = (offProduct.product_name?.isEmpty == false) ? offProduct.product_name! : ""
                
                let category = offProduct.categories_tags?.last
                    .map {
                        $0.replacingOccurrences(of: "en:", with: "")
                            .replacingOccurrences(of: "-", with: " ")
                            .capitalized
                    } ?? "Other"
                
                let product = Product(
                    name: name,
                    quantity: 1,
                    createdAt: ISO8601DateFormatter().string(from: Date()),
                    category: category
                )
                
                DispatchQueue.main.async {
                    completion(.success(product))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
        }
        task.resume()
    }
}
