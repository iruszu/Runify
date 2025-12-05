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
        var paceHistory: [Double] // Last 20 pace readings for chart
    }

    // Fixed non-changing properties about your activity go here!
    var runId: String
    var startTime: Date
}

struct RunifyWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RunifyWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack(alignment: .leading, spacing: 10) {
                // Header
                HStack {
                    Image(systemName: "figure.run")
                        .font(.title3)
                        .foregroundColor(.orange)
                    Text("Runify")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                    Spacer()
                    Text(formatTime(context.state.elapsedTime))
                        .font(.headline)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .foregroundColor(.orange)
                }
                
                Divider()
                    .background(Color.orange.opacity(0.3))
                
                // Main stats row
                HStack(spacing: 16) {
                    // Distance
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Distance")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(formatDistance(context.state.distance))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Pace
                    VStack(alignment: .center, spacing: 2) {
                        Text("Pace")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(formatPace(context.state.pace))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Calories (if available)
                    if let calories = context.state.calories {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Calories")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text("\(calories)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                Text("kcal")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // Pace Chart
                if !context.state.paceHistory.isEmpty {
                    Chart {
                        ForEach(Array(context.state.paceHistory.enumerated()), id: \.offset) { index, pace in
                            LineMark(
                                x: .value("Time", index),
                                y: .value("Pace", pace > 0 ? pace : 0.0)
                            )
                            .foregroundStyle(.orange)
                            .interpolationMethod(.catmullRom)
                        }
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .frame(height: 40)
                    .padding(.vertical, 4)
                }
                
                // Location and buttons row
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(context.state.locationName)
                            .font(.caption)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    HStack(spacing: 8) {
                        Button(intent: PauseRunIntent()) {
                            Image(systemName: "pause.circle.fill")
                                .font(.title3)
                                .foregroundColor(.orange)
                        }
                        .buttonStyle(.plain)
                        
                        Button(intent: StopRunIntent()) {
                            Image(systemName: "stop.circle.fill")
                                .font(.title3)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
            .activityBackgroundTint(Color.orange.opacity(0.1))
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
    fileprivate static var running: RunifyWidgetAttributes.ContentState {
        RunifyWidgetAttributes.ContentState(
            distance: 2500,
            elapsedTime: 900,
            pace: 6.0,
            locationName: "Central Park",
            calories: 150,
            paceHistory: [6.2, 6.1, 6.0, 5.9, 6.0, 6.1, 6.0, 5.8, 6.0, 6.1, 6.0, 5.9, 6.0]
        )
    }
     
    fileprivate static var longerRun: RunifyWidgetAttributes.ContentState {
        RunifyWidgetAttributes.ContentState(
            distance: 5000,
            elapsedTime: 1800,
            pace: 6.0,
            locationName: "Riverside Trail",
            calories: 320,
            paceHistory: [6.5, 6.3, 6.2, 6.1, 6.0, 5.9, 6.0, 6.1, 6.0, 5.8, 6.0, 6.1, 6.0, 5.9, 6.0, 6.1, 6.0, 5.8, 6.0]
        )
    }
}

#Preview("Notification", as: .content, using: RunifyWidgetAttributes.preview) {
   RunifyWidgetLiveActivity()
} contentStates: {
    RunifyWidgetAttributes.ContentState.running
    RunifyWidgetAttributes.ContentState.longerRun
}
