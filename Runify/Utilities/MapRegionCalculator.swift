//
//  MapRegionCalculator.swift
//  Runify
//
//  Created by Kellie Ho on 2025-01-27.
//

import Foundation
import MapKit

/// Utility class for calculating map regions that encompass run routes
struct MapRegionCalculator {
    
    /// Calculates a bounding region that encompasses the entire run path
    /// - Parameter run: The run object containing location data
    /// - Returns: An MKCoordinateRegion that frames the entire run route
    static func calculateBoundingRegion(for run: Run) -> MKCoordinateRegion {
        // Get all coordinates from the run
        var allCoordinates: [CLLocationCoordinate2D] = []
        
        // Add start location if available
        if let startLocation = run.startLocation {
            allCoordinates.append(startLocation.clCoordinate)
        }
        
        // Add all route coordinates
        allCoordinates.append(contentsOf: run.locations.map { $0.clCoordinate })
        
        // If no coordinates, return default region
        guard !allCoordinates.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        
        return calculateBoundingRegion(for: allCoordinates)
    }
    
    /// Calculates a bounding region for a set of coordinates
    /// - Parameter coordinates: Array of CLLocationCoordinate2D points
    /// - Returns: An MKCoordinateRegion that frames all the coordinates
    static func calculateBoundingRegion(for coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        guard !coordinates.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        
        // Calculate bounding box
        let latitudes = coordinates.map { $0.latitude }
        let longitudes = coordinates.map { $0.longitude }
        
        let minLat = latitudes.min() ?? 0
        let maxLat = latitudes.max() ?? 0
        let minLon = longitudes.min() ?? 0
        let maxLon = longitudes.max() ?? 0
        
        // Calculate center
        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2
        let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
        
        // Calculate span with padding
        let latDelta = max((maxLat - minLat) * 1.2, 0.001) // Add 20% padding, minimum 0.001
        let lonDelta = max((maxLon - minLon) * 1.2, 0.001) // Add 20% padding, minimum 0.001
        
        return MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        )
    }
    
    /// Calculates a bounding region for route coordinates only (used in RunSummaryCard)
    /// - Parameter run: The run object containing location data
    /// - Returns: An MKCoordinateRegion that frames the route coordinates
    static func calculateRouteRegion(for run: Run) -> MKCoordinateRegion {
        guard !run.locations.isEmpty else {
            // Fallback to start location if no route data
            if let startLocation = run.startLocation {
                return MKCoordinateRegion(
                    center: startLocation.clCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
            // Default region if no location data
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        
        let coordinates = run.locations.map { $0.clCoordinate }
        return calculateBoundingRegion(for: coordinates)
    }
}
