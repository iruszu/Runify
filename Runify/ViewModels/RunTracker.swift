//
//  RunTracker.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-18.
//

import Foundation
import SwiftUI
import MapKit
import SwiftData
import Observation

enum MapStyleOption: String, CaseIterable {
    case standard = "Standard"
    case imagery = "Imagery"
    case hybrid = "Hybrid"
    
    var mapStyle: MapStyle {
        switch self {
        case .standard:
            return .standard(elevation: .realistic)
        case .imagery:
            return .imagery(elevation: .realistic)
        case .hybrid:
            return .hybrid(elevation: .realistic)
        }
    }
    
    var description: String {
        switch self {
        case .standard:
            return "Classic road map with labels"
        case .imagery:
            return "Satellite imagery view"
        case .hybrid:
            return "Satellite with road labels"
        }
    }
    
    var icon: String {
        switch self {
        case .standard:
            return "map"
        case .imagery:
            return "globe"
        case .hybrid:
            return "map.fill"
        }
    }
}


@Observable
class RunTracker: NSObject, CLLocationManagerDelegate {
    //MKCoordinateSpan defines how much of the map should be visible
    var region = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 49.2593, longitude: -123.247), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
    var staticRegion = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 49.2593, longitude: -123.247), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))) // Static region for MapView
    
    var isRunning = false // Track if the user is currently running
    var distance: Double = 0.0 // Track the distance run
    var pace = 0.0
    var elapsedTime = 0.0 // Track the elapsed time of the run
    private var modelContext: ModelContext? 
    
    // Location tracking
    private var locationManager: CLLocationManager?
    var startLocation: CLLocation?
    var lastLocation: CLLocation?
    var locations: [CLLocation] = [] // Array to store all location points for route drawing
    var mapStyle: MapStyle = .imagery(elevation: .realistic) // Shared map style for all map views
    var mapStyleOption: MapStyleOption = .imagery // Track the selected map style option
    
    // Planned route data (when running to a destination)
    var plannedDestinationName: String?
    var plannedDestinationCoordinate: CLLocationCoordinate2D?
    var plannedRouteCoordinates: [CLLocationCoordinate2D] = []
    
    private let timerManager = TimerManager()
    private var runStartTime: Date?
    private var currentRunId: UUID?
    private var liveActivityManager: LiveActivityManager?
    private var currentLocationName: String = "Starting..."
    private var healthKitManager: HealthKitManager?
    private var paceHistory: [Double] = [] // Track pace history for chart
    private var caloriesBurned: Int = 0 // Track calories during run
    
    func setLiveActivityManager(_ manager: LiveActivityManager) {
        self.liveActivityManager = manager
    }
    
    func setHealthKitManager(_ manager: HealthKitManager) {
        self.healthKitManager = manager
    }
    
    override init() {
        super.init()
        
        // Listen for pause/stop notifications from widget
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePauseRun),
            name: NSNotification.Name("PauseRun"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStopRun),
            name: NSNotification.Name("StopRun"),
            object: nil
        )
        
        // Request location data
        Task {
            await MainActor.run {
                // Sets up location manager for tracking
                locationManager = CLLocationManager()
                // delegate is an object that handles events on behalf of another object, so it sends its location to this class (RunTracker)
                locationManager?.delegate = self
                
                // Configure location accuracy and activity type for running
                // Using kCLLocationAccuracyBest for precise running tracking
                locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                locationManager?.distanceFilter = 10 // Update every 10 meters (Apple's recommendation)
                locationManager?.activityType = .fitness // Optimized for running/fitness activities
                
                // Request When In Use authorization (better privacy than Always)
                // Combined with allowsBackgroundLocationUpdates for background tracking during runs
                locationManager?.requestWhenInUseAuthorization()
                locationManager?.startUpdatingLocation() // Start updating location
            }
        }
    }
    
    @objc private func handlePauseRun() {
        if isRunning {
            pauseRun()
        }
    }
    
    @MainActor @objc private func handleStopRun() {
        if isRunning {
            stopRun()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    /// Enable background location updates - call this when starting a run
    /// Following Apple's recommended approach: When In Use + background updates
    private func enableBackgroundLocationIfNeeded() {
        guard let locationManager = locationManager else { return }
        
        // Enable background updates for When In Use authorization
        // This shows the location indicator when app is in background (better transparency)
        if locationManager.authorizationStatus == .authorizedWhenInUse || 
           locationManager.authorizationStatus == .authorizedAlways {
            locationManager.allowsBackgroundLocationUpdates = true
            print("✅ Background location updates enabled")
        } else {
            print("⚠️ Location authorization required for background updates")
        }
    }
    
    /// Disable background location updates - call this when stopping/pausing a run
    private func disableBackgroundLocation() {
        locationManager?.allowsBackgroundLocationUpdates = false
        print("🔴 Background location updates disabled")
    }
    
    
    // When the user starts a run, we want to start tracking their location
    @MainActor func startRun() {
        startLocation = nil // Reset start location because a new run is starting
        lastLocation = nil // Reset last location
        locations = [] // Clear previous route (actual path)
        // Note: plannedRoute data is NOT cleared here - it's set from AppCoordinator
        isRunning = true // Set running state to true
        
        distance = 0.0 // Reset distance
        pace = 0.0 // Reset pace
        elapsedTime = 0.0 // Reset elapsed time
        currentLocationName = "Starting..."
        paceHistory = [] // Reset pace history
        caloriesBurned = 0 // Reset calories
        
        // Generate unique ID for this run
        currentRunId = UUID()
        runStartTime = Date()
        
        // Start tracking calories from HealthKit if available
        if let healthKit = healthKitManager, healthKit.isAuthorized {
            // Calories will be tracked via HealthKit workout session
            // We'll estimate based on distance and time if HealthKit isn't available
        }
        
        // Start Live Activity
        if let runId = currentRunId?.uuidString, let startTime = runStartTime {
            liveActivityManager?.startLiveActivity(
                runId: runId,
                startTime: startTime,
                locationName: currentLocationName
            )
        }
        
        // Enable background location if possible
        enableBackgroundLocationIfNeeded()
        
        // Start timer using TimerManager
        timerManager.startTimer(interval: 1.0, repeats: true) { [weak self] in
            guard let self = self else { return }
            
            self.elapsedTime += 1.0 // Increment elapsed time every second
            
            if self.distance > 0 {
                self.pace = (Double(self.elapsedTime) / 60) / (self.distance / 1000) // Calculate pace in minutes per kilometer
                
                // Add to pace history (every 5 seconds to avoid too much data)
                if Int(self.elapsedTime) % 5 == 0 && self.pace > 0 {
                    self.paceHistory.append(self.pace)
                    // Keep only last 20 readings
                    if self.paceHistory.count > 20 {
                        self.paceHistory.removeFirst()
                    }
                }
            }
            
            // Estimate calories if not available from HealthKit
            // Rough estimate: ~60 calories per km for average runner
            if self.caloriesBurned == 0 && self.distance > 0 {
                let estimatedCalories = Int((self.distance / 1000.0) * 60)
                self.caloriesBurned = estimatedCalories
            }
            
            // Update Live Activity every second
            self.liveActivityManager?.updateLiveActivity(
                distance: self.distance,
                elapsedTime: self.elapsedTime,
                pace: self.pace,
                locationName: self.currentLocationName,
                calories: self.caloriesBurned > 0 ? self.caloriesBurned : nil,
                paceHistory: self.paceHistory
            )
        }
        
        locationManager?.startUpdatingLocation() // Start updating location when the run starts
    }
    
    func pauseRun() {
        locationManager?.stopUpdatingLocation() // Stop updating location when the run is paused
        timerManager.pauseTimer()
        isRunning = false
    }
    
    func resumeRun() {
        locationManager?.startUpdatingLocation() // Resume location updates
        timerManager.resumeTimer(interval: 1.0, repeats: true) { [weak self] in
            guard let self = self else { return }
            
            self.elapsedTime += 1.0 // Increment elapsed time every second
            
            if self.distance > 0 {
                self.pace = (Double(self.elapsedTime) / 60) / (self.distance / 1000) // Calculate pace in minutes per kilometer
            }
        }
        isRunning = true
    }
    
    @MainActor func stopRun() {
        // Capture the current location as the final position before stopping updates
        if let currentLocation = locationManager?.location {
            locations.append(currentLocation)
            lastLocation = currentLocation
        }
        
        // End Live Activity
        liveActivityManager?.endLiveActivity()
        
        locationManager?.stopUpdatingLocation() // Stop updating location when the run stops
        disableBackgroundLocation() // Disable background location updates
        timerManager.stopTimer()
        isRunning = false
        
        // Capture values before resetting run tracking variables
        let capturedRunStartTime = runStartTime
        let capturedStartLocation = startLocation
        let capturedDistance = distance
        let capturedElapsedTime = elapsedTime
        let capturedPace = pace
        let capturedPlannedDestinationName = plannedDestinationName
        
        // Create a Coordinate object from the start location
        let startCoordinate = startLocation.map { Coordinate($0.coordinate, sequenceIndex: 0) }
        
        // Convert CLLocation array to Coordinate array with sequence indices
        let routeCoordinates = locations.enumerated().map { index, location in
            Coordinate(location.coordinate, sequenceIndex: index)
        }
        
        // Convert planned route coordinates to Coordinate array (if exists) with sequence indices
        let plannedRouteCoords = plannedRouteCoordinates.isEmpty ? nil : plannedRouteCoordinates.enumerated().map { index, coord in
            Coordinate(coord, sequenceIndex: index)
        }
        let destinationCoord = plannedDestinationCoordinate.map { Coordinate($0) }
        
        // Use captured runStartTime for the date, or current date if not available
        let runDate = capturedRunStartTime ?? Date()
        
        // Reset run tracking variables
        currentRunId = nil
        runStartTime = nil
        
        // Get location name using reverse geocoding
        getLocationName(from: capturedStartLocation) { [weak self] locationName in
            guard let self = self else { return }
            
            let completedRun = Run(
                locationName: locationName,
                date: runDate,
                distance: capturedDistance,
                duration: capturedElapsedTime,
                pace: capturedPace > 0 ? capturedPace : 0.0, // Ensure pace is non-negative
                startLocation: startCoordinate,
                locations: routeCoordinates,
                isFavorited: false,
                destinationName: capturedPlannedDestinationName,
                destinationCoordinate: destinationCoord,
                plannedRoute: plannedRouteCoords
            )
            
            // Only save valid runs
            // Check validity manually to provide better error messages
            let isValid = capturedDistance > 0 && 
                         capturedElapsedTime > 0 && 
                         capturedPace >= 0 && // Allow pace to be 0 for very short runs
                         !locationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            
            if isValid {
                // Save to shared data for widget
                let sharedData = SharedRunData(
                    distance: capturedDistance,
                    duration: capturedElapsedTime,
                    pace: capturedPace,
                    locationName: locationName,
                    date: runDate,
                    isRunning: false
                )
                SharedRunData.saveRecentRun(sharedData)
                
                if let context = self.modelContext {
                    // Save on main actor since ModelContext requires main thread
                    Task { @MainActor in
                        context.insert(completedRun)
                        do {
                            try context.save()
                            print("✅ Run saved successfully: \(completedRun.id)")
                            print("   Distance: \(completedRun.formattedDistance)")
                            print("   Duration: \(completedRun.formattedTime)")
                            print("   Pace: \(completedRun.formattedPace)")
                            print("   Date: \(completedRun.formattedDate)")
                            print("   Location: \(completedRun.locationName)")
                        } catch {
                            print("❌ Failed to save run: \(error.localizedDescription)")
                            print("   Error details: \(error)")
                        }
                    }
                } else {
                    print("⚠️ ModelContext is nil - run not saved")
                    print("   Make sure setModelContext() is called in TabView")
                }
            } else {
                print("⚠️ Run is not valid - not saving")
                print("   Distance: \(capturedDistance)m (required: > 0)")
                print("   Duration: \(capturedElapsedTime)s (required: > 0)")
                print("   Pace: \(capturedPace) min/km (required: >= 0)")
                print("   LocationName: '\(locationName)' (required: non-empty)")
            }
            
            // Clear planned route data after saving
            self.clearPlannedRoute()
        }
    }
    
    // MARK: - Reverse Geocoding

    private func getLocationName(from location: CLLocation?, completion: @escaping (String) -> Void) {
        guard let location = location else {
            completion("Unknown Location")
            return
        }

        // Use MKReverseGeocodingRequest for iOS 26.0+
        guard let request = MKReverseGeocodingRequest(location: location) else {
            completion("Unknown Location")
            return
        }

        Task {
            do {
                let mapItems = try await request.mapItems

                await MainActor.run {
                    guard let mapItem = mapItems.first else {
                        completion("Unknown Location")
                        return
                    }

                    // Try to get a meaningful location name
                    var locationName = "Unknown Location"

                    if let name = mapItem.name {
                        locationName = name
                    } else if let fullAddress = mapItem.addressRepresentations?.fullAddress(includingRegion: true, singleLine: true) {
                        locationName = fullAddress
                    }

                    completion(locationName)
                }
            } catch {
                await MainActor.run {
                    print("Reverse geocoding error: \(error.localizedDescription)")
                    completion("Unknown Location")
                }
            }
        }
    }
}

// MARK: Location Tracking
extension RunTracker {
    
    // grabs the users' most recent location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Always process all provided locations (Apple's recommendation)
        for location in locations {
            processLocationUpdate(location)
        }
    }
    
    /// Process and validate a single location update
    /// Following Apple's best practices for location validation
    private func processLocationUpdate(_ location: CLLocation) {
        Task {
            await MainActor.run {
                // Validate location before using it
                guard isLocationValid(location) else {
                    print("⚠️ Location rejected: \(location.coordinate)")
                    return
                }
                
                // Always update the region to follow user's location
                region = .region(
                    MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )
                
                // Add location to route array for drawing
                self.locations.append(location)
                
                // Checks if this is the first location update
                if startLocation == nil {
                    startLocation = location // saves the starting location
                    lastLocation = location // saves the last location
                    
                    // Get location name for Live Activity
                    self.getLocationName(from: location) { [weak self] locationName in
                        self?.currentLocationName = locationName
                        // Update Live Activity with initial location
                        self?.liveActivityManager?.updateLiveActivity(
                            distance: self?.distance ?? 0,
                            elapsedTime: self?.elapsedTime ?? 0,
                            pace: self?.pace ?? 0,
                            locationName: locationName
                        )
                    }
                    return
                }
                
                if let lastLocation {
                    distance += lastLocation.distance(from: location) // calculates the distance from the last location to the current location
                }
                
                lastLocation = location // updates the last location so we can track the distance
                
                // Update location name periodically (every 100 meters or every 30 seconds)
                if self.locations.count % 10 == 0 || self.elapsedTime.truncatingRemainder(dividingBy: 30) < 1 {
                    self.getLocationName(from: location) { [weak self] locationName in
                        guard let self = self else { return }
                        self.currentLocationName = locationName
                        // Update Live Activity with new location
                        self.liveActivityManager?.updateLiveActivity(
                            distance: self.distance,
                            elapsedTime: self.elapsedTime,
                            pace: self.pace,
                            locationName: locationName
                        )
                    }
                }
            }
        }
    }
    
    /// Validate location data following Apple's recommendations
    /// Returns true if the location should be used for tracking
    private func isLocationValid(_ newLocation: CLLocation) -> Bool {
        // 1. Check timestamp - ensure location is recent (within last 60 seconds)
        // This filters out cached values from when location services start up
        let locationAge = Date().timeIntervalSince(newLocation.timestamp)
        guard locationAge < 60 else {
            print("Location too old: \(locationAge)s")
            return false
        }
        
        // 2. Keep first few locations to establish initial position
        guard locations.count > 10 else { return true }
        
        // 3. Check minimum distance between points
        // Using 5 meters for smoother route visualization (balance between accuracy and smoothness)
        // Apple recommends 10m for battery optimization, but 5m gives smoother lines
        guard let lastLocation = locations.last else { return true }
        let minimumDistanceInMeters = 5.0
        let metersApart = newLocation.distance(from: lastLocation)
        
        if metersApart < minimumDistanceInMeters {
            print("Location too close: \(metersApart)m")
            return false
        }
        
        return true
    }
    
    // MARK: - Planned Route Methods
    
    /// Set planned route data from AppCoordinator
    func setPlannedRoute(destinationName: String, coordinate: CLLocationCoordinate2D, polyline: MKPolyline) {
        self.plannedDestinationName = destinationName
        self.plannedDestinationCoordinate = coordinate
        self.plannedRouteCoordinates = polyline.coordinates()
    }
    
    /// Clear planned route data
    func clearPlannedRoute() {
        plannedDestinationName = nil
        plannedDestinationCoordinate = nil
        plannedRouteCoordinates = []
    }
    
    /// Calculate distance remaining to destination
    func distanceToDestination() -> Double? {
        guard let lastLocation = lastLocation,
              let destination = plannedDestinationCoordinate else {
            return nil
        }
        
        let destinationLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        return lastLocation.distance(from: destinationLocation)
    }

}

// MARK: - MKPolyline Extension

extension MKPolyline {
    /// Extract coordinates from MKPolyline
    func coordinates() -> [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}
