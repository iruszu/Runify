//
//  LiveActivityManager.swift
//  Runify
//
//  Created by Kellie Ho on 2025-12-05.
//

import Foundation
import ActivityKit
import WidgetKit

// Shared Activity Attributes - must match RunifyWidgetLiveActivity.swift
struct RunifyWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var distance: Double // in meters
        var elapsedTime: TimeInterval // in seconds
        var pace: Double // min/km
        var locationName: String
        var calories: Int? // calories burned (optional)
        var paceHistory: [Double] // Last 20 pace readings for chart
    }
    
    var runId: String
    var startTime: Date
}

@MainActor
class LiveActivityManager: ObservableObject {
    @Published var currentActivity: Activity<RunifyWidgetAttributes>?
    
    private var updateTimer: Timer?
    
    /// Start a Live Activity for a run
    func startLiveActivity(
        runId: String,
        startTime: Date,
        locationName: String = "Starting..."
    ) {
        // Check if Live Activities are available
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("⚠️ Live Activities are not enabled")
            return
        }
        
        let attributes = RunifyWidgetAttributes(
            runId: runId,
            startTime: startTime
        )
        
        let initialState = RunifyWidgetAttributes.ContentState(
            distance: 0,
            elapsedTime: 0,
            pace: 0,
            locationName: locationName,
            calories: nil,
            paceHistory: []
        )
        
        do {
            let activity = try Activity<RunifyWidgetAttributes>.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            
            currentActivity = activity
            print("✅ Live Activity started: \(runId)")
            
            // Start periodic updates
            startUpdateTimer()
        } catch {
            print("❌ Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    /// Update the Live Activity with current run data
    func updateLiveActivity(
        distance: Double,
        elapsedTime: TimeInterval,
        pace: Double,
        locationName: String,
        calories: Int? = nil,
        paceHistory: [Double] = []
    ) {
        guard let activity = currentActivity else { return }
        
        // Get existing pace history and add new pace
        var updatedPaceHistory = activity.content.state.paceHistory
        if pace > 0 {
            updatedPaceHistory.append(pace)
            // Keep only last 20 readings
            if updatedPaceHistory.count > 20 {
                updatedPaceHistory.removeFirst()
            }
        }
        
        // Use provided paceHistory if available, otherwise use updated one
        let finalPaceHistory = paceHistory.isEmpty ? updatedPaceHistory : paceHistory
        
        let updatedState = RunifyWidgetAttributes.ContentState(
            distance: distance,
            elapsedTime: elapsedTime,
            pace: pace,
            locationName: locationName,
            calories: calories,
            paceHistory: finalPaceHistory
        )
        
        Task {
            await activity.update(
                .init(state: updatedState, staleDate: nil)
            )
        }
        
        // Also update shared data for widget
        let sharedData = SharedRunData(
            distance: distance,
            duration: elapsedTime,
            pace: pace,
            locationName: locationName,
            date: Date(),
            isRunning: true,
            elapsedTime: elapsedTime,
            startTime: activity.attributes.startTime
        )
        SharedRunData.saveActiveRun(sharedData)
    }
    
    /// End the Live Activity
    func endLiveActivity() {
        // Stop update timer first
        stopUpdateTimer()
        
        // Clear active run data immediately
        SharedRunData.clearActiveRun()
        
        // End all running activities (in case currentActivity reference is lost)
        Task {
            // Get all running activities for this app
            let runningActivities = Activity<RunifyWidgetAttributes>.activities
            
            for activity in runningActivities {
                // Get final state from activity
                let finalState = RunifyWidgetAttributes.ContentState(
                    distance: activity.content.state.distance,
                    elapsedTime: activity.content.state.elapsedTime,
                    pace: activity.content.state.pace,
                    locationName: activity.content.state.locationName,
                    calories: activity.content.state.calories,
                    paceHistory: activity.content.state.paceHistory
                )
                
                // End with immediate dismissal
                await activity.end(
                    .init(state: finalState, staleDate: nil),
                    dismissalPolicy: .immediate
                )
                print("✅ Ended Live Activity: \(activity.attributes.runId)")
            }
            
            // Force widget refresh to update Control Center widget and other widgets
            WidgetCenter.shared.reloadAllTimelines()
        }
        
        // Clear current activity reference
        currentActivity = nil
        
        print("✅ Live Activity cleanup completed")
    }
    
    /// Start a timer to periodically update the Live Activity
    private func startUpdateTimer() {
        stopUpdateTimer() // Make sure we don't have multiple timers
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                // This will be called from RunTracker's update method
                // The timer is just to ensure we have a mechanism for updates
            }
        }
    }
    
    /// Stop the update timer
    private func stopUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
}

// Import the widget attributes from the widget extension
// Note: In a real app, you'd typically share this in a shared framework
// For now, we'll need to make sure RunifyWidgetAttributes is accessible
// This might require creating a shared target or duplicating the struct

