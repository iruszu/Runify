//
//  RunDTO.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-30.
//


import Foundation
import SwiftData
import MapKit

@Model
final class Run {
    @Attribute(.unique) var id: UUID
    var locationName: String
    var date: Date
    var distance: Double // in meters
    var duration: TimeInterval
    var pace: Double // min/km
    var startLocation: Coordinate? // Starting location of the run
    
    init(locationName: String, date: Date, distance: Double, duration: TimeInterval, pace: Double, startLocation: Coordinate? = nil) {
        self.id = UUID()
        self.locationName = locationName
        self.date = date
        self.distance = distance
        self.duration = duration
        self.pace = pace
        self.startLocation = startLocation
    }
    
    // Keep your existing computed properties
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedTime: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        if hours > 0 {
            return minutes > 0 ? "\(hours) hour \(minutes) min" : "\(hours) hour"
        } else {
            return "\(minutes) min"
        }
    }
}






// Coordinate also needs to be a Swift Data model
@Model
final class Coordinate {
    var latitude: Double
    var longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // Convenience initializer from CLLocationCoordinate2D
    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    // Convert back to CLLocationCoordinate2D
    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
