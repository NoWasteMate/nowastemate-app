//
//  ProductService.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2025-11-27.
//

//References:
// https://gurjit-singh.medium.com/how-to-use-completion-handler-in-swift-d1c26b30c67
// https://www.hackingwithswift.com/quick-start/concurrency/how-to-use-continuations-to-convert-completion-handlers-into-async-functions
// https://www.hackingwithswift.com/forums/swift/help-needed-json-encoding/17744
// https://developer.apple.com/documentation/dispatch/dispatchqueue/main

import Foundation
import FirebaseAuth


// is an array, not a string, so that decode is allowed to fail and falls back.
enum BarcodeLookupError: LocalizedError {
    case notFound(String)
    case unsupported
    case unauthorized
    case retry(String)

    var errorDescription: String? {
        switch self {
        case .notFound(let message): return message
        case .unsupported: return "This barcode isn't supported"
        case .unauthorized: return "Please sign in again"
        case .retry(let message): return message
        }
    }
}

private nonisolated struct BackendErrorDetail: Decodable {
    let detail: String
}

//Protocol lets previews inject a sample data service instead of calling the backend. https://developer.apple.com/videos/play/wwdc2020/10149/
// around 22mins
protocol ProductServiceProtocol {
    func getProducts(user: User, completionHandler: @escaping (Result<[Product], Error>) -> Void)
    func addProduct(user: User, product: Product, completionHandler: @escaping (Result<Void, Error>) -> Void)
    func deleteProduct(user: User, product: Product, completionHandler: @escaping (Result<[Product], Error>) -> Void)
    func editProduct(user: User, product: Product, completionHandler: @escaping (Result<Void, Error>) -> Void)
    func getBarcodeDetails(user: User, barcode: String, completionHandler: @escaping (Result<Product, Error>) -> Void)
}

struct ProductService: ProductServiceProtocol {
    static let shared = ProductService()
    
    //Getting the list of products depending on user
    func getProducts(user: User, completionHandler: @escaping (Result<[Product], Error>) -> Void){
        user.getIDTokenForcingRefresh(true) { idToken, error in
          if let error = error {
            print(error)
            DispatchQueue.main.async {
                completionHandler(.failure(error))
            }
            return;
          }
            let url = URL(string: "\(AppConfig.baseUrl)/getProducts")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) {data, _, error in
                guard let data = data, error == nil else {

                    DispatchQueue.main.async {
                        completionHandler(.failure(error ?? URLError(.badServerResponse)))
                    }
                    return
                }
                do {
                    //let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    //print(response)
                    
                    let products = try JSONDecoder().decode([Product].self, from: data)
                    print(products)
                    DispatchQueue.main.async {
                        completionHandler(.success(products))
                    }

                }
                
                catch {
                    print(error)
                    DispatchQueue.main.async {
                        completionHandler(.failure(error))
                    }
                }
            }
            task.resume()

        }
        
    }
    
    func addProduct(user: User, product: Product, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        user.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                DispatchQueue.main.async { completionHandler(.failure(error)) }
                return;
            }
            
            let url = URL(string: "\(AppConfig.baseUrl)/products")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            
            let encoder = JSONEncoder()
            
            do {
                request.httpBody = try encoder.encode(product)
            } catch {
                DispatchQueue.main.async { completionHandler(.failure(error)) }
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) {data, _, error in
                guard data != nil, error == nil else {
                    DispatchQueue.main.async {
                        completionHandler(.failure(error ?? URLError(.badServerResponse)))
                    }
                    return
                }
                DispatchQueue.main.async { completionHandler(.success(())) }
            }
            task.resume()
            
        }
        
    }
    
    func deleteProduct(user: User, product: Product, completionHandler: @escaping (Result<[Product], Error>) -> Void) {
        user.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print(error)
                return;
            }
            
            let url = URL(string: "\(AppConfig.baseUrl)/deleteProduct/\(product.id ?? "")")!
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) {data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                do {
                    let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print(response)
                }
                
                catch {
                    print(error)
                }
                
                
            }
            task.resume()
        }
            
    }
    
    func editProduct(user: User, product: Product, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        user.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print(error)
                return;
            }
            let url = URL(string: "\(AppConfig.baseUrl)/putProduct/\(product.id ?? "")")!
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let encoder = JSONEncoder()
            
            do {
                request.httpBody = try encoder.encode(product)
            } catch {
                print("Failed to encode object: \(error)")
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) {data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                do {
                    let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print(response)
                    DispatchQueue.main.async {
                        completionHandler(.success(()))
                    }
                }
                
                catch {
                    print(error)
                    DispatchQueue.main.async {
                        completionHandler(.failure(error))
                    }
                }
            }
            task.resume()

        }
    }
    
    func getBarcodeDetails(user: User, barcode: String, completionHandler: @escaping (Result<Product, Error>) -> Void) {
        user.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print(error)
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
                return
            }
            let url = URL(string: "\(AppConfig.baseUrl)/getBarcodeDetails/\(barcode)")!
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
                    let detail = (try? JSONDecoder().decode(BackendErrorDetail.self, from: data))?.detail
                    let failure: BarcodeLookupError
                    
                    switch statusCode {
                    case 401: failure = .unauthorized
                    case 404: failure = .notFound(detail ?? "Product not found, add manually")
                    case 422: failure = .unsupported
                    default:  failure = .retry(detail ?? "Barcode service unavailable, try again")
                    }
                    
                    print("getBarcodeDetails failed: \(statusCode) \(detail ?? "")")
                    DispatchQueue.main.async {
                        completionHandler(.failure(failure))
                    }
                    return
                }
                
                do {
                    let product = try JSONDecoder().decode(Product.self, from: data)
                    DispatchQueue.main.async {
                        completionHandler(.success(product))
                    }
                } catch {
                    print(error)
                    DispatchQueue.main.async {
                        completionHandler(.failure(error))
                    }
                }
            }
            task.resume()
        }
        
    }

}
