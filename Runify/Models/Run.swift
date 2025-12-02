//
//  Run.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-30.
//

import Foundation
import SwiftData
import MapKit

/// Represents a completed running session with location and performance data
@Model
final class Run: Hashable { //final means we can't create a subcalss from it
    // MARK: - Properties
    
    @Attribute(.unique) var id: UUID
    var locationName: String
    var date: Date
    var distance: Double // in meters
    var duration: TimeInterval // in seconds
    var pace: Double // min/km
    var startLocation: Coordinate?
    var locations: [Coordinate] // Route coordinates (actual path taken)
    var isFavorited: Bool = false // Track if run is favorited
    
    // Planned route data (if run was started from a destination)
    var destinationName: String?
    var destinationCoordinate: Coordinate?
    var plannedRoute: [Coordinate]? // The intended path from MKDirections
    
    
    init(
        locationName: String,
        date: Date = Date(),
        distance: Double,
        duration: TimeInterval,
        pace: Double,
        startLocation: Coordinate? = nil,
        locations: [Coordinate] = [],
        isFavorited: Bool = false,
        destinationName: String? = nil,
        destinationCoordinate: Coordinate? = nil,
        plannedRoute: [Coordinate]? = nil
    ) {
        self.id = UUID()
        self.locationName = locationName
        self.date = date
        self.distance = distance
        self.duration = duration
        self.pace = pace
        self.startLocation = startLocation
        self.locations = locations
        self.isFavorited = isFavorited
        self.destinationName = destinationName
        self.destinationCoordinate = destinationCoordinate
        self.plannedRoute = plannedRoute
    }
    
    // MARK: - Computed Properties
    
    /// Formatted date string for display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /// Formatted time duration for display
    var formattedTime: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    /// Distance in kilometers
    var distanceInKilometers: Double {
        distance / 1000.0
    }
    
    /// Distance in miles
    var distanceInMiles: Double {
        distance * 0.000621371
    }
    
    /// Average speed in km/h
    var averageSpeed: Double {
        guard duration > 0 else { return 0 }
        return (distance / 1000.0) / (duration / 3600.0)
    }
    
    /// Average speed in mph
    var averageSpeedInMPH: Double {
        averageSpeed * 0.621371
    }
    
    /// Pace in minutes per mile
    var paceInMinutesPerMile: Double {
        pace * 1.60934
    }
    
    /// Formatted distance string with appropriate units
    var formattedDistance: String {
        if distance >= 1000 {
            return String(format: "%.2f km", distanceInKilometers)
        } else {
            return String(format: "%.0f m", distance)
        }
    }
    
    /// Formatted pace string
    var formattedPace: String {
        String(format: "%.1f min/km", pace)
    }
    
    /// Formatted average speed string
    var formattedAverageSpeed: String {
        String(format: "%.1f km/h", averageSpeed)
    }
    
    
    var isValid: Bool {
        return distance > 0 &&
               duration > 0 &&
               pace > 0 &&
               !locationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
        
    /// Updates the run with new data
    func update(
        locationName: String? = nil,
        distance: Double? = nil,
        duration: TimeInterval? = nil,
        pace: Double? = nil,
        startLocation: Coordinate? = nil,
        locations: [Coordinate]? = nil,
        isFavorited: Bool? = nil,
        destinationName: String? = nil,
        destinationCoordinate: Coordinate? = nil,
        plannedRoute: [Coordinate]? = nil
    ) {
        if let locationName = locationName {
            self.locationName = locationName
        }
        if let distance = distance {
            self.distance = distance
        }
        if let duration = duration {
            self.duration = duration
        }
        if let pace = pace {
            self.pace = pace
        }
        if let startLocation = startLocation {
            self.startLocation = startLocation
        }
        if let locations = locations {
            self.locations = locations
        }
        if let isFavorited = isFavorited {
            self.isFavorited = isFavorited
        }
        if let destinationName = destinationName {
            self.destinationName = destinationName
        }
        if let destinationCoordinate = destinationCoordinate {
            self.destinationCoordinate = destinationCoordinate
        }
        if let plannedRoute = plannedRoute {
            self.plannedRoute = plannedRoute
        }
    }
    
    /// Toggles the favorite status of the run
    func toggleFavorite() {
        isFavorited.toggle()
    }
}

// MARK: - Coordinate Model

/// Represents a geographical coordinate
@Model
final class Coordinate {
    var latitude: Double
    var longitude: Double
    var sequenceIndex: Int = 0 // Preserves order in route sequence
    
    // MARK: - Initialization
    
    init(latitude: Double, longitude: Double, sequenceIndex: Int = 0) {
        self.latitude = latitude
        self.longitude = longitude
        self.sequenceIndex = sequenceIndex
    }
    
    /// Convenience initializer from CLLocationCoordinate2D
    init(_ coordinate: CLLocationCoordinate2D, sequenceIndex: Int = 0) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.sequenceIndex = sequenceIndex
    }
    
    // MARK: - Computed Properties
    
    /// Convert back to CLLocationCoordinate2D
    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// Check if coordinate is valid
    var isValid: Bool {
        return latitude >= -90 && latitude <= 90 &&
               longitude >= -180 && longitude <= 180
    }
    
    // MARK: - Utility Methods
    
    /// Calculate distance to another coordinate in meters
    func distance(to other: Coordinate) -> Double {
        let location1 = CLLocation(latitude: latitude, longitude: longitude)
        let location2 = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return location1.distance(from: location2)
    }
}
