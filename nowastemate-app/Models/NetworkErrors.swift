//
//  NetworkErrors.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 22/11/2026.
//

//ref https://stackoverflow.com/a/67951732
//ref https://www.kodeco.com/books/swiftui-cookbook/v1.0/chapters/12-handle-errors-with-an-alert-in-swiftui

import Foundation

enum NetworkErrors: LocalizedError {
    case responseIsNotHTTP
    case noDataProvided
    case internalError
    case notFound
    case unauthorized
    case forbidden
    case unknown
    
    
    var errorDescription: String? {
        switch self {
        case .responseIsNotHTTP:
            return "Bad response received"
        case .noDataProvided:
            return "No data received"
        case .internalError:
            return "An internal error occured"
        case .notFound:
            return "Object not found"
        case .unauthorized:
            return "Invalid Authentication"
        case .forbidden:
            return "This action is not allowed with your permissions"
        case .unknown:
            return "An unknown error has occured"
        }
      }
}
