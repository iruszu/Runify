//
//  LiveActivityManager.swift
//  Runify
//
//  Manages Live Activities for run tracking
//

import Foundation
import ActivityKit
import SwiftUI

@available(iOS 16.1, *)
@MainActor
class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<RunActivityAttributes>?
    
    // Track last update state to avoid unnecessary updates
    private var lastUpdateState: RunActivityAttributes.ContentState?
    
    private init() {}
    
    /// Start a Live Activity for an active run
    func startActivity(
        runId: UUID,
        startTime: Date,
        destinationName: String? = nil
    ) {
        // Check if ActivityKit is available
        let authInfo = ActivityAuthorizationInfo()
        print("🔍 Live Activity Authorization:")
        print("   - Are activities enabled: \(authInfo.areActivitiesEnabled)")
        print("   - Frequent pushes enabled: \(authInfo.frequentPushesEnabled)")
        
        guard authInfo.areActivitiesEnabled else {
            print("⚠️ Live Activities are not enabled in Settings")
            print("   Please enable in: Settings > Runify > Live Activities")
            return
        }
        
        // Check if there's already an activity running
        if currentActivity != nil {
            print("⚠️ Live Activity already running, ending previous one")
            endActivity(finalDistance: nil, finalTime: nil)
        }
        
        // Reset last update state
        lastUpdateState = nil
        
        let attributes = RunActivityAttributes(
            runId: runId,
            startTime: startTime,
            destinationName: destinationName
        )
        
        let initialContentState = RunActivityAttributes.ContentState(
            distance: 0.0,
            elapsedTime: 0.0,
            pace: 0.0,
            isPaused: false,
            currentLocation: nil
        )
        
        do {
            let activity = try Activity<RunActivityAttributes>.request(
                attributes: attributes,
                content: ActivityContent(state: initialContentState, staleDate: nil),
                pushType: .token // Enable push token for server-driven updates
            )
            currentActivity = activity
            print("✅ Live Activity started successfully")
            print("   Activity ID: \(activity.id)")
            print("   Check Lock Screen and Dynamic Island (iPhone 14 Pro+)")
            
            // Monitor push token for server-driven updates (optional)
            Task {
                await monitorPushToken(for: activity)
            }
        } catch {
            print("❌ Failed to start Live Activity: \(error.localizedDescription)")
            print("   Error details: \(error)")
        }
    }
    
    /// Update the Live Activity with current run data
    /// Only updates if content has actually changed (performance optimization)
    func updateActivity(
        distance: Double,
        elapsedTime: TimeInterval,
        pace: Double,
        isPaused: Bool,
        currentLocation: String? = nil
    ) {
        guard let activity = currentActivity else { return }
        
        let updatedState = RunActivityAttributes.ContentState(
            distance: distance,
            elapsedTime: elapsedTime,
            pace: pace,
            isPaused: isPaused,
            currentLocation: currentLocation
        )
        
        // Performance optimization: Only update if state has changed significantly
        // This prevents unnecessary updates when values haven't changed meaningfully
        if let lastState = lastUpdateState {
            // Check if values have changed meaningfully (avoid micro-updates)
            let distanceChanged = abs(lastState.distance - distance) >= 10 // 10 meters
            let timeChanged = abs(lastState.elapsedTime - elapsedTime) >= 1.0 // 1 second
            let paceChanged = abs(lastState.pace - pace) >= 0.1 // 0.1 min/km
            let pauseStateChanged = lastState.isPaused != isPaused
            
            // Only update if something meaningful changed
            if !distanceChanged && !timeChanged && !paceChanged && !pauseStateChanged {
                return // Skip update - no meaningful change
            }
        }
        
        lastUpdateState = updatedState
        
        // Set stale date to 1 hour from now (content becomes stale after 1 hour)
        let staleDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
        
        Task {
            await activity.update(ActivityContent(state: updatedState, staleDate: staleDate))
        }
    }
    
    /// End the Live Activity (when run stops)
    func endActivity(finalDistance: Double? = nil, finalTime: TimeInterval? = nil) {
        guard let activity = currentActivity else { return }
        
        Task {
            // Create final state with completion data
            let finalState = RunActivityAttributes.ContentState(
                distance: finalDistance ?? 0.0,
                elapsedTime: finalTime ?? 0.0,
                pace: 0.0,
                isPaused: false,
                currentLocation: "Run Complete"
            )
            
            // End with final state and dismiss after 5 seconds (gives user time to see completion)
            await activity.end(
                ActivityContent(state: finalState, staleDate: nil),
                dismissalPolicy: .after(.now.addingTimeInterval(5))
            )
            
            await MainActor.run {
                currentActivity = nil
                lastUpdateState = nil // Reset state tracking
            }
            print("✅ Live Activity ended")
        }
    }
    
    /// Monitor push token for server-driven updates
    private func monitorPushToken(for activity: Activity<RunActivityAttributes>) async {
        for await pushToken in activity.pushTokenUpdates {
            let tokenString = pushToken.reduce("") { $0 + String(format: "%02x", $1) }
            print("📱 Live Activity Push Token: \(tokenString)")
            print("   Activity ID: \(activity.id)")
            // TODO: Send token to your server for remote updates
            // await sendPushTokenToServer(tokenString, activityId: activity.id)
        }
    }
    
    /// Check if a Live Activity is currently active
    var isActive: Bool {
        return currentActivity != nil
    }
}

