

import Foundation

/// Centralized configuration for API keys, base URLs, and request settings

import Foundation

struct APIConfiguration {
    // MARK: - Google Maps Configuration
    static var googleMapsAPIKey: String {
        
        if let key = Bundle.main.infoDictionary?["GOOGLE_MAPS_API_KEY"] as? String, !key.isEmpty {
            return key
        }

        return "YOUR_API_KEY_HERE"
    }
    
    static let googleMapsRoutesBaseURL = "https://routes.googleapis.com"
    static let googleMapsPlacesBaseURL = "https://places.googleapis.com" // For future use
    
    // MARK: - Request Configuration
    static let requestTimeout: TimeInterval = 30.0
    static let defaultHeaders: [String: String] = [
        "Content-Type": "application/json"
    ]

}
