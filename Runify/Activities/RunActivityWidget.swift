//
//  RunActivityWidget.swift
//  Runify
//
//  Live Activity widget view for run tracking
//

import SwiftUI
import WidgetKit
import ActivityKit

@available(iOS 16.1, *)
struct RunActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RunActivityAttributes.self) { context in
            // Lock Screen UI
            LockScreenLiveActivityView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.8))
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI in Dynamic Island
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Runify")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                        Text(formatDistance(context.state.distance))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(formatTime(context.state.elapsedTime))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text(formatPace(context.state.pace))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 20) {
                        VStack {
                            Text("Distance")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                            Text(formatDistance(context.state.distance))
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        VStack {
                            Text("Pace")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                            Text(formatPace(context.state.pace))
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        if context.state.isPaused {
                            Image(systemName: "pause.circle.fill")
                                .foregroundColor(.orange)
                                .font(.title2)
                        }
                    }
                    .padding(.top, 8)
                }
            } compactLeading: {
                // Compact leading (left side of Dynamic Island)
                Image(systemName: context.state.isPaused ? "pause.circle" : "figure.run")
                    .foregroundColor(context.state.isPaused ? .orange : .green)
            } compactTrailing: {
                // Compact trailing (right side of Dynamic Island)
                Text(formatTime(context.state.elapsedTime))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            } minimal: {
                // Minimal view (when multiple activities are active)
                Image(systemName: context.state.isPaused ? "pause.circle" : "figure.run")
                    .foregroundColor(context.state.isPaused ? .orange : .green)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func formatDistance(_ meters: Double) -> String {
        if meters >= 1000 {
            return String(format: "%.2f km", meters / 1000)
        } else {
            return String(format: "%.0f m", meters)
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) % 3600 / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
    
    private func formatPace(_ pace: Double) -> String {
        guard pace > 0 else { return "--:--" }
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Lock Screen View

@available(iOS 16.1, *)
struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<RunActivityAttributes>
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side - Distance
            VStack(alignment: .leading, spacing: 4) {
                Text("Distance")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                Text(formatDistance(context.state.distance))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Center - Time and Status
            VStack(spacing: 4) {
                if context.state.isPaused {
                    Image(systemName: "pause.circle.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                } else {
                    Image(systemName: "figure.run")
                        .foregroundColor(.green)
                        .font(.title2)
                }
                Text(formatTime(context.state.elapsedTime))
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Right side - Pace
            VStack(alignment: .trailing, spacing: 4) {
                Text("Pace")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                Text(formatPace(context.state.pace))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .padding()
    }
    
    private func formatDistance(_ meters: Double) -> String {
        if meters >= 1000 {
            return String(format: "%.2f km", meters / 1000)
        } else {
            return String(format: "%.0f m", meters)
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) % 3600 / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
    
    private func formatPace(_ pace: Double) -> String {
        guard pace > 0 else { return "--:--" }
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d:%02d", minutes, seconds)
    }
}

