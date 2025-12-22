//
//  RunifyWidgetLiveActivity.swift
//  RunifyWidget
//
//  Created by Kellie Ho on 2025-12-05.
//

import ActivityKit
import WidgetKit
import SwiftUI
import Charts
import AppIntents

struct RunifyWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var distance: Double // in meters
        var elapsedTime: TimeInterval // in seconds
        var pace: Double // min/km
        var locationName: String
        var calories: Int? // calories burned (optional)
        var heartRate: Int? // current heart rate in BPM (optional)
        var paceHistory: [Double] // Last 20 pace readings for chart
        var distanceToDestination: Double? // Distance remaining to destination (in meters)
        var totalRouteDistance: Double? // Total distance of planned route (in meters)
    }

    // Fixed non-changing properties about your activity go here!
    var runId: String
    var startTime: Date
}

struct RunifyWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RunifyWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here - Native Apple style with time, distance, and HealthKit data
            VStack(spacing: 12) {
                // Main stats row - Time and Distance
                HStack(spacing: 16) {
                    // Time - left side
                    VStack(alignment: .leading) {
                        Text(formatTime(context.state.elapsedTime))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .monospacedDigit()
                            .foregroundColor(.primary)
                        Text("Time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Distance - right side
                    VStack(alignment: .leading) {
                        Text(formatDistance(context.state.distance))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Text("Distance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // HealthKit data row - Heart Rate and Calories (if available)
                if context.state.heartRate != nil || context.state.calories != nil {
                    HStack(spacing: 16) {
                        // Heart Rate
                        if let heartRate = context.state.heartRate {
                            HStack(spacing: 6) {
                                Image(systemName: "heart.fill")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                Text("\(heartRate)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Text("BPM")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Calories
                        if let calories = context.state.calories {
                            HStack(spacing: 6) {
                                Image(systemName: "flame.fill")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                Text("\(calories)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Text("kcal")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } else {
                    // Alternative data row - Pace and Location (when HealthKit data not available)
                    HStack(spacing: 16) {
                        // Pace
                        if context.state.pace > 0 {
                            HStack(spacing: 6) {
                                Image(systemName: "speedometer")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Text(formatPace(context.state.pace))
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Text("min/km")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Location
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(context.state.locationName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                    }
                }
                
                // Progress bar for planned route
                if let distanceToDest = context.state.distanceToDestination,
                   let totalDistance = context.state.totalRouteDistance,
                   totalDistance > 0 {
                    VStack(alignment: .leading, spacing: 4) {
                        let progress = max(0, min(1, (totalDistance - distanceToDest) / totalDistance))
                        
                        ProgressView(value: progress)
                            .tint(.orange)
                            .scaleEffect(x: 1, y: 1.5, anchor: .center)
                        
                        HStack {
                            Text(String(format: "%.1f km", distanceToDest / 1000))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(String(format: "%.1f km", totalDistance / 1000))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
            .activityBackgroundTint(Color.clear)
            .activitySystemActionForegroundColor(Color.orange)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Distance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatDistance(context.state.distance))
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Pace")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatPace(context.state.pace))
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(formatTime(context.state.elapsedTime))
                                .font(.title)
                                .fontWeight(.bold)
                                .monospacedDigit()
                            Spacer()
                        }
                        HStack {
                            Image(systemName: "location.fill")
                                .font(.caption)
                            Text(context.state.locationName)
                                .font(.subheadline)
                                .lineLimit(1)
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: "figure.run")
                    .foregroundColor(.orange)
            } compactTrailing: {
                Text(formatTime(context.state.elapsedTime))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .monospacedDigit()
            } minimal: {
                Image(systemName: "figure.run")
                    .foregroundColor(.orange)
            }
            .widgetURL(URL(string: "runify://run"))
            .keylineTint(Color.orange)
        }
    }
    
    // Helper functions for formatting
    private func formatDistance(_ distance: Double) -> String {
        if distance >= 1000 {
            return String(format: "%.2f km", distance / 1000.0)
        } else {
            return String(format: "%.0f m", distance)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) % 3600 / 60
        let seconds = Int(time) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    private func formatPace(_ pace: Double) -> String {
        guard pace > 0 else { return "-- min/km" }
        return String(format: "%.1f", pace)
    }
}

extension RunifyWidgetAttributes {
    fileprivate static var preview: RunifyWidgetAttributes {
        RunifyWidgetAttributes(
            runId: UUID().uuidString,
            startTime: Date()
        )
    }
}

extension RunifyWidgetAttributes.ContentState {
    // Preview with HealthKit data (calories and heart rate)
    fileprivate static var withHealthKit: RunifyWidgetAttributes.ContentState {
        RunifyWidgetAttributes.ContentState(
            distance: 2500,
            elapsedTime: 900,
            pace: 6.0,
            locationName: "Central Park",
            calories: 150,
            heartRate: 145,
            paceHistory: [6.2, 6.1, 6.0, 5.9, 6.0, 6.1, 6.0, 5.8, 6.0, 6.1, 6.0, 5.9, 6.0],
            distanceToDestination: nil,
            totalRouteDistance: nil
        )
    }
    
    // Preview without HealthKit data (shows pace and location instead)
    fileprivate static var withoutHealthKit: RunifyWidgetAttributes.ContentState {
        RunifyWidgetAttributes.ContentState(
            distance: 3200,
            elapsedTime: 1200,
            pace: 6.25,
            locationName: "Riverside Trail",
            calories: nil,
            heartRate: nil,
            paceHistory: [6.5, 6.3, 6.2, 6.1, 6.0, 5.9, 6.0, 6.1, 6.0, 5.8, 6.0],
            distanceToDestination: nil,
            totalRouteDistance: nil
        )
    }
}

#Preview("Notification", as: .content, using: RunifyWidgetAttributes.preview) {
   RunifyWidgetLiveActivity()
} contentStates: {
    RunifyWidgetAttributes.ContentState.withHealthKit
    RunifyWidgetAttributes.ContentState.withoutHealthKit
}
