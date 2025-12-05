//
//  RunActivityAttributes.swift
//  Runify
//
//  ActivityKit attributes for Live Activity run tracking
//

import Foundation
import ActivityKit

/// Attributes for the Run Live Activity
struct RunActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic content that updates during the run
        var distance: Double // in meters
        var elapsedTime: TimeInterval // in seconds
        var pace: Double // min/km
        var isPaused: Bool
        var currentLocation: String? // Location name (optional)
    }
    
    // Static attributes that don't change
    var runId: UUID
    var startTime: Date
    var destinationName: String? // If running to a destination
}

