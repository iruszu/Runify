//
//  SharedRunData.swift
//  RunifyWidget
//
//  Created by Kellie Ho on 2025-12-05.
//

import Foundation

/// Shared data structure for passing run data between main app and widget extension
struct SharedRunData: Codable, Identifiable {
    var id: Date { date }
    var distance: Double // in meters
    var duration: TimeInterval // in seconds
    var pace: Double // min/km
    var locationName: String
    var date: Date
    var isRunning: Bool
    
    // For active runs
    var elapsedTime: TimeInterval?
    var startTime: Date?
    
    static let appGroupIdentifier = "group.com.kellieho.Runify"
    
    /// Save recent run data to shared UserDefaults
    static func saveRecentRun(_ run: SharedRunData) {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            print("⚠️ Failed to access App Group UserDefaults")
            return
        }
        
        if let encoded = try? JSONEncoder().encode(run) {
            sharedDefaults.set(encoded, forKey: "recentRun")
            sharedDefaults.synchronize()
        }
    }
    
    /// Load recent run data from shared UserDefaults
    static func loadRecentRun() -> SharedRunData? {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = sharedDefaults.data(forKey: "recentRun"),
              let run = try? JSONDecoder().decode(SharedRunData.self, from: data) else {
            return nil
        }
        return run
    }
    
    /// Save multiple recent runs (up to 5 most recent)
    static func saveRecentRuns(_ runs: [SharedRunData]) {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            print("⚠️ Failed to access App Group UserDefaults")
            return
        }
        
        // Keep only the 5 most recent runs
        let recentRuns = Array(runs.sorted { $0.date > $1.date }.prefix(5))
        
        if let encoded = try? JSONEncoder().encode(recentRuns) {
            sharedDefaults.set(encoded, forKey: "recentRuns")
            sharedDefaults.synchronize()
        }
        
        // Also save the most recent one for backward compatibility
        if let mostRecent = recentRuns.first {
            saveRecentRun(mostRecent)
        }
    }
    
    /// Load multiple recent runs from shared UserDefaults
    static func loadRecentRuns() -> [SharedRunData] {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = sharedDefaults.data(forKey: "recentRuns"),
              let runs = try? JSONDecoder().decode([SharedRunData].self, from: data) else {
            // Fallback to single run for backward compatibility
            if let singleRun = loadRecentRun() {
                return [singleRun]
            }
            return []
        }
        return runs.sorted { $0.date > $1.date }
    }
    
    /// Save active run data
    static func saveActiveRun(_ run: SharedRunData) {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            return
        }
        
        if let encoded = try? JSONEncoder().encode(run) {
            sharedDefaults.set(encoded, forKey: "activeRun")
            sharedDefaults.synchronize()
        }
    }
    
    /// Load active run data
    static func loadActiveRun() -> SharedRunData? {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = sharedDefaults.data(forKey: "activeRun"),
              let run = try? JSONDecoder().decode(SharedRunData.self, from: data) else {
            return nil
        }
        return run
    }
    
    /// Clear active run data
    static func clearActiveRun() {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            return
        }
        sharedDefaults.removeObject(forKey: "activeRun")
        sharedDefaults.synchronize()
    }
    
    /// Format distance for display
    var formattedDistance: String {
        if distance >= 1000 {
            return String(format: "%.2f km", distance / 1000.0)
        } else {
            return String(format: "%.0f m", distance)
        }
    }
    
    /// Format time duration for display
    var formattedTime: String {
        let time = elapsedTime ?? duration
        let hours = Int(time) / 3600
        let minutes = Int(time) % 3600 / 60
        let seconds = Int(time) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    /// Format pace for display
    var formattedPace: String {
        guard pace > 0 else { return "-- min/km" }
        return String(format: "%.1f min/km", pace)
    }
}

