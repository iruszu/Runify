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


class RunTracker: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 49.2593, longitude: -123.247), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
    
    @Published var isRunning = false // Track if the user is currently running
    @Published var distance: Double = 0.0 // Track the distance run
    @Published var pace = 0.0
    @Published var elapsedTime = 0.0 // Track the elapsed time of the run
    private var modelContext: ModelContext? 
    
    // Location tracking
    private var locationManager: CLLocationManager?
     var startLocation: CLLocation?
     var lastLocation: CLLocation?
    
    private let timerManager = TimerManager()
    
    override init() {
        super.init()
        
        // Request location data
        Task {
            await MainActor.run {
                // Sets up location manager for tracking
                locationManager = CLLocationManager()
                locationManager?.delegate = self
                locationManager?.requestWhenInUseAuthorization()
                locationManager?.startUpdatingLocation() // Start updating location
            }
        }
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // When the user starts a run, we want to start tracking their location
    func startRun() {
        startLocation = nil // Reset start location because a new run is starting
        lastLocation = nil // Reset last location
        isRunning = true // Set running state to true
        
        distance = 0.0 // Reset distance
        pace = 0.0 // Reset pace
        elapsedTime = 0.0 // Reset elapsed time
        
        // Start timer using TimerManager
        timerManager.startTimer(interval: 1.0, repeats: true) { [weak self] in
            guard let self = self else { return }
            
            self.elapsedTime += 1.0 // Increment elapsed time every second
            
            if self.distance > 0 {
                self.pace = (Double(self.elapsedTime) / 60) / (self.distance / 1000) // Calculate pace in minutes per kilometer
            }
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
    
    func stopRun() {
        locationManager?.stopUpdatingLocation() // Stop updating location when the run stops
        timerManager.stopTimer()
        isRunning = false
        
        // Create a Coordinate object from the start location
        let startCoordinate = startLocation.map { Coordinate($0.coordinate) }
        
        let completedRun = Run(
            locationName: "Current Location",
            date: Date(),
            distance: distance,
            duration: elapsedTime,
            pace: pace,
            startLocation: startCoordinate
        )
        
        // Only save valid runs
        if completedRun.isValid, let context = modelContext {
            context.insert(completedRun)
            try? context.save()
        }
    }
     
    
}

// MARK: Location Tracking
extension RunTracker {
    
    // grabs the users' most recent location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task {
            //update region to the user's current location
            await MainActor.run {
                
                // Recreate the region with the new location
                region = .region(
                    MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )
                
                // Checks if this is the first location update
                if startLocation == nil {
                    startLocation = location // saves the starting location
                    lastLocation = location // saves the last location
                    return
                }
                
                if let lastLocation {
                    distance += lastLocation.distance(from: location) // calculates the distance from the last location to the current location
                }
                
                lastLocation = location // updates the last location so we can track the distance
            }
        }
        }
    
    
        

}
