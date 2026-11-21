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
// https://developer.apple.com/documentation/visionkit/datascannerviewcontroller/recognizeddatatype/barcode(symbologies:)
// https://developer.apple.com/documentation/swift/sequence/allsatisfy(_:)


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

enum ProductOutcomeError: LocalizedError {
    case notFound
    case alreadyMarked
    case unauthorized
    case failed(String)

    var errorDescription: String? {
        switch self {
        case .notFound: return "This product could not be found"
        case .alreadyMarked: return "This product was already marked"
        case .unauthorized: return "Please sign in again"
        case .failed(let message): return message
        }
    }
}

// https://developer.apple.com/documentation/foundation/localizederror
enum ProductRequestError: LocalizedError, Equatable {
    case unauthorized
    case notFound(String)
    case invalid
    case server(String)
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:        return "Please sign in again"
        case .notFound(let msg):   return msg
        case .invalid:             return "Some product details aren't valid"
        case .server(let msg):     return msg
        }
    }
}

extension ProductService {
    // status code + body -> error
    // https://developer.apple.com/documentation/foundation/httpurlresponse/statuscode
    // https://fastapi.tiangolo.com/tutorial/handling-errors/
    // https://www.youtube.com/watch?v=gpPa0zf51bI
    // https://www.youtube.com/watch?v=gpPa0zf51bI
    // https://www.youtube.com/watch?v=xVZCAdB9lpg
    
    nonisolated static func mapError(statusCode: Int, data: Data?) -> ProductRequestError {
        let detail = data.flatMap { try? JSONDecoder().decode(BackendErrorDetail.self, from: $0)}?.detail
        
        switch statusCode {
        // 403 = missing bearer token from HTTPBearer
        case 401, 403: return .unauthorized
        case 404: return .notFound(detail ?? "This product could not be found")
        case 422: return .invalid
        default: return .server(detail ?? "Something went wrong, try again")
        }
    }
    
    static func request(_ path: String, method: String, token: String, body: Data? = nil) throws -> URLRequest {
        guard let url = URL(string: "\(AppConfig.baseUrl)\(path)") else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        if let body {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }
        return request
    }
    
    // when user gets token, it gets the request and status check then decode
    // https://developer.apple.com/documentation/dispatch/dispatchqueue/main
    // https://developer.apple.com/documentation/swift/result
    func send<T>(user: User, makeRequest: @escaping (_ token: String) throws -> URLRequest, decode: @escaping (Data) throws -> T, completion: @escaping (Result<T, Error>) -> Void) {
        
        func finish(_ result: Result<T, Error>) {
            DispatchQueue.main.async { completion(result) }
        }
        
        user.getIDTokenForcingRefresh(true) {
            idToken, error in
            if let error { finish(.failure(error)); return }
            guard let idToken else {
                finish(.failure(ProductRequestError.unauthorized));
                return
            }
            
            let request: URLRequest
            do {
                request = try makeRequest(idToken)
            } catch {
                finish(.failure(error));
                return
            }
            
            URLSession.shared.dataTask(with: request) {
                data, response, error in
                if let error {
                    finish(.failure(error)); return
                }
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                guard (200..<300).contains(statusCode) else {
                    print("\(request.httpMethod ?? "") \(request.url?.path ?? "") failed: \(statusCode)")
                    
                    finish(.failure(Self.mapError(statusCode: statusCode, data: data)))
                    return
                }
                do {
                    finish(.success(try decode(data ?? Data())))
                }
                catch {
                    finish(.failure(error))
                }
            }.resume()
        }
    }
}

//Protocol lets previews inject a sample data service instead of calling the backend. https://developer.apple.com/videos/play/wwdc2020/10149/
// around 22mins
protocol ProductServiceProtocol {
    func getProducts(user: User, completionHandler: @escaping (Result<[Product], Error>) -> Void)
    func addProduct(user: User, product: Product, completionHandler: @escaping (Result<Void, Error>) -> Void)
    func deleteProduct(user: User, product: Product, completionHandler: @escaping (Result<[Product], Error>) -> Void)
    func editProduct(user: User, product: Product, completionHandler: @escaping (Result<Void, Error>) -> Void)
    func getBarcodeDetails(user: User, barcode: String, completionHandler: @escaping (Result<Product, Error>) -> Void)
    func markProductOutcome(user: User, product: Product, outcome: ProductOutcome, wasteReason: WasteReason?, completionHandler: @escaping (Result<Void, Error>) -> Void)
    func getWasteDiagnostic(user: User, product: Product, completionHandler: @escaping (Result<WasteReason, Error>) -> Void)
    func getFamilyProducts(user: User, completionHandler: @escaping (Result<[Product], Error>) -> Void)
}

struct ProductService: ProductServiceProtocol {
    static let shared = ProductService()
    
    //Getting the list of products depending on user
    //Error handling references:
    // https://m.youtube.com/watch?v=tADAlisn4HA
    // https://www.youtube.com/watch?v=aTj0ZLha1zE
    func getProducts(user: User, completionHandler: @escaping (Result<[Product], Error>) -> Void){
        
        send(user: user, makeRequest: { try Self.request("/getProducts", method: "GET", token: $0) }, decode: { try JSONDecoder().decode([Product].self, from: $0) }, completion: completionHandler)
        
//        user.getIDTokenForcingRefresh(true) { idToken, error in
//          if let error = error {
//            print(error)
//            DispatchQueue.main.async {
//                completionHandler(.failure(error))
//            }
//            return;
//          }
//            let url = URL(string: "\(AppConfig.baseUrl)/getProducts")!
//            var request = URLRequest(url: url)
//            request.httpMethod = "GET"
//            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
//            
//            let task = URLSession.shared.dataTask(with: request) {data, _, error in
//                guard let data = data, error == nil else {
//
//                    DispatchQueue.main.async {
//                        completionHandler(.failure(error ?? URLError(.badServerResponse)))
//                    }
//                    return
//                }
//                do {
//                    //let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
//                    //print(response)
//                    
//                    let products = try JSONDecoder().decode([Product].self, from: data)
//                    print(products)
//                    DispatchQueue.main.async {
//                        completionHandler(.success(products))
//                    }
//
//                }
//                
//                catch {
//                    print(error)
//                    DispatchQueue.main.async {
//                        completionHandler(.failure(error))
//                    }
//                }
//            }
//            task.resume()
//
//        }
        
    }
    
    // getting every family member's active products
    func getFamilyProducts(user: User, completionHandler: @escaping (Result<[Product], Error>) -> Void){
        
        send(user: user,
            makeRequest: { try Self.request("/getFamilyProducts", method: "GET", token: $0) },
             decode: { try JSONDecoder().decode([Product].self, from: $0) }) { result in
            // 404 = "not in a family", which is an empty list, not an error
            if case .failure(let error) = result, case .notFound? = error as? ProductRequestError {
                completionHandler(.success([]))
            } else {
                completionHandler(result)
            }
        }
        
//        user.getIDTokenForcingRefresh(true) { idToken, error in
//            if let error = error {
//                DispatchQueue.main.async { completionHandler(.failure(error)) }
//                return
//            }
//            let url = URL(string: "\(AppConfig.baseUrl)/getFamilyProducts")!
//            var request = URLRequest(url: url)
//            request.httpMethod = "GET"
//            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
//            
//            let task = URLSession.shared.dataTask(with: request) { data, _, error in
//                guard let data = data, error == nil else {
//                    DispatchQueue.main.async { completionHandler(.failure(error ?? URLError(.badServerResponse))) }
//                    return
//                }
//                do {
//                    let products = try JSONDecoder().decode([Product].self, from: data)
//                    DispatchQueue.main.async { completionHandler(.success(products)) }
//                } catch {
//                    DispatchQueue.main.async { completionHandler(.failure(error)) }
//                }
//            }
//            task.resume()
//        }
    }
    
    // references for POST requests
    // https://www.youtube.com/watch?v=aTj0ZLha1zE
    // https://www.youtube.com/watch?v=st8MMg4hQ3g
    
    func addProduct(user: User, product: Product, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        
        send(user: user, makeRequest: { try Self.request("/products", method: "POST", token: $0, body: JSONEncoder().encode(product)) }, decode: { _ in () }, completion: completionHandler)
        
//        user.getIDTokenForcingRefresh(true) { idToken, error in
//            if let error = error {
//                DispatchQueue.main.async { completionHandler(.failure(error)) }
//                return;
//            }
//            
//            let url = URL(string: "\(AppConfig.baseUrl)/products")!
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            
//            
//            let encoder = JSONEncoder()
//            
//            do {
//                request.httpBody = try encoder.encode(product)
//            } catch {
//                DispatchQueue.main.async { completionHandler(.failure(error)) }
//                return
//            }
//            
//            let task = URLSession.shared.dataTask(with: request) {data, _, error in
//                guard data != nil, error == nil else {
//                    DispatchQueue.main.async {
//                        completionHandler(.failure(error ?? URLError(.badServerResponse)))
//                    }
//                    return
//                }
//                DispatchQueue.main.async { completionHandler(.success(())) }
//            }
//            task.resume()
//            
//        }
        
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
        
        
        guard let id = product.id else {
            DispatchQueue.main.async {
                completionHandler(.failure(ProductRequestError.notFound("This product could not be found")))
            }
            return
        }
        send(user: user, makeRequest: { try Self.request("/putProduct/\(id)", method: "PUT", token: $0, body: JSONEncoder().encode(product)) }, decode: { _ in () }, completion: completionHandler)
        
//        user.getIDTokenForcingRefresh(true) { idToken, error in
//            if let error = error {
//                print(error)
//                return;
//            }
//            let url = URL(string: "\(AppConfig.baseUrl)/putProduct/\(product.id ?? "")")!
//            var request = URLRequest(url: url)
//            request.httpMethod = "PUT"
//            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            
//            let encoder = JSONEncoder()
//            
//            do {
//                request.httpBody = try encoder.encode(product)
//            } catch {
//                print("Failed to encode object: \(error)")
//                return
//            }
//            
//            let task = URLSession.shared.dataTask(with: request) {data, _, error in
//                guard let data = data, error == nil else {
//                    return
//                }
//                do {
//                    let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
//                    print(response)
//                    DispatchQueue.main.async {
//                        completionHandler(.success(()))
//                    }
//                }
//                
//                catch {
//                    print(error)
//                    DispatchQueue.main.async {
//                        completionHandler(.failure(error))
//                    }
//                }
//            }
//            task.resume()
//
//        }
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
            let isValid = barcode.count >= 8 && barcode.count <= 14
            && barcode.allSatisfy(\.isNumber)
            guard isValid,
                  let url = URL(string: "\(AppConfig.baseUrl)/getBarcodeDetails/\(barcode)") else {
                DispatchQueue.main.async { completionHandler(.failure(BarcodeLookupError.unsupported)) }
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
    
    // marks a product consumed or wasted (soft delete, the backend keeps the document for analytics)
    // same shape as getBarcodeDetails: every path calls the completion on the main queue
    func markProductOutcome(user: User, product: Product, outcome: ProductOutcome, wasteReason: WasteReason?, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        user.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print(error)
                DispatchQueue.main.async { completionHandler(.failure(error)) }
                return
            }
            guard let productId = product.id,
                  let url = URL(string: "\(AppConfig.baseUrl)/markProductOutcome/\(productId)") else {
                DispatchQueue.main.async { completionHandler(.failure(ProductOutcomeError.notFound)) }
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            var body = ["outcome": outcome.rawValue]
            if let wasteReason { body["wasteReason"] = wasteReason.rawValue }
            
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                DispatchQueue.main.async { completionHandler(.failure(error)) }
                return
            }
            
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
                    let failure: ProductOutcomeError
                    
                    switch statusCode {
                    case 401: failure = .unauthorized
                    case 404: failure = .notFound
                    case 409: failure = .alreadyMarked
                    default:  failure = .failed(detail ?? "Couldn't mark the product, try again")
                    }
                    
                    print("markProductOutcome failed: \(statusCode) \(detail ?? "")")
                    DispatchQueue.main.async { completionHandler(.failure(failure)) }
                    return
                }
                DispatchQueue.main.async { completionHandler(.success(())) }
            }
            task.resume()
        }
    }
    
    // references for error handling:
    // https://www.youtube.com/watch?v=Tw_WLMIfEPQ
    // https://www.youtube.com/shorts/HnjUEGboFu8
    // https://developer.apple.com/documentation/swift/checkedcontinuation
    //  https://www.hackingwithswift.com/quick-start/concurrency/how-to-use-continuations-to-convert-completion-handlers-into-async-functions
    func getWasteDiagnostic(user: User, product: Product, completionHandler: @escaping (Result<WasteReason, Error>) -> Void){
        
        guard let id = product.id else {
            DispatchQueue.main.async { completionHandler(.failure(ProductOutcomeError.notFound)) }
            return
        }
        send(user: user, makeRequest: { try Self.request("/get_waste_diagnostic/\(id)", method: "GET", token: $0) }, decode: { try JSONDecoder().decode(WasteReason.self, from: $0) }, completion: completionHandler)
//        user.getIDTokenForcingRefresh(true) { idToken, error in
//          if let error = error {
//            print(error)
//            return;
//          }
//            guard let productId = product.id,
//                  let url = URL(string: "\(AppConfig.baseUrl)/get_waste_diagnostic/\(productId)") else {
//                completionHandler(.failure(ProductOutcomeError.notFound)) 
//                return
//            }
//            var request = URLRequest(url: url)
//            request.httpMethod = "GET"
//            request.addValue("Bearer \(idToken ?? "")", forHTTPHeaderField: "Authorization")
//            
//            let task = URLSession.shared.dataTask(with: request) {data, _, error in
//                guard let data = data, error == nil else {
//                    return
//                }
//                do {
//                    
//                    let reason = try JSONDecoder().decode(WasteReason.self, from: data)
//                              completionHandler(.success(reason))
//                }
//                
//                catch {
//                    print(error)
//                    completionHandler(.failure(error))
//                    
//                }
//            }
//            task.resume()
//            
//        }
    }

}
