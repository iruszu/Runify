import SwiftUI
import Foundation
import MapKit

class AppCoordinator: ObservableObject {
    @Published var navigationStack: [Int] = []
    
    // Navigation state
    @Published var showCountdown = false
    @Published var showRun = false
    @Published var showRunSummary = false
    @Published var showRunningMap = false
    
    // Planned route data (set when starting run from a destination)
    @Published var plannedDestinationName: String?
    @Published var plannedDestinationCoordinate: CLLocationCoordinate2D?
    @Published var plannedRoutePolyline: MKPolyline?
    
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
