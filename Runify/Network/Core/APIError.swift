//
//  APIError.swift
//  Runify
//
//  Created by Kellie Ho on 2025-10-13.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(statusCode: Int)
    case decodingFailed(Error)
    case encodingFailed(Error)
    case networkError(Error)
    case noData
    case unauthorized
    case forbidden
    case notFound
    case serverError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid"
        case .invalidResponse:
            return "Received an invalid response from the server"
        case .requestFailed(let statusCode):
            return "Request failed with status code: \(statusCode)"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingFailed(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .noData:
            return "No data received from server"
        case .unauthorized:
            return "Unauthorized access - please check your API key"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error occurred"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
