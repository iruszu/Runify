import SwiftUI
import Foundation
import MapKit
import Observation

@Observable
class AppCoordinator {
    var navigationStack: [Int] = []
    
    // Navigation state
    var showCountdown = false
    var showRun = false
    var showRunSummary = false
    var showRunningMap = false
    
    // Planned route data (set when starting run from a destination)
    var plannedDestinationName: String?
    var plannedDestinationCoordinate: CLLocationCoordinate2D?
    var plannedRoutePolyline: MKPolyline?
    
    // Navigation methods
    func navigateToCountdown() {
        showCountdown = true
    }
    
    func countdownFinished() {
        showCountdown = false
        showRunningMap = true
    }

    
    func stopRun() {
        showRunningMap = false
        showRunSummary = true
    }
    
    func finishRunSummary() {
        showRunSummary = false
    }

    
    func resetToHome() {
        navigationStack.removeAll()
        showCountdown = false
        showRun = false
        showRunSummary = false
        showRunningMap = false
        clearPlannedRoute()
    }
    
    // MARK: - Planned Route Methods
    
    /// Set planned route data when starting run to a destination
    func setPlannedRoute(destinationName: String, coordinate: CLLocationCoordinate2D, polyline: MKPolyline) {
        self.plannedDestinationName = destinationName
        self.plannedDestinationCoordinate = coordinate
        self.plannedRoutePolyline = polyline
    }
    
    /// Clear planned route data
    func clearPlannedRoute() {
        plannedDestinationName = nil
        plannedDestinationCoordinate = nil
        plannedRoutePolyline = nil
    }
}
