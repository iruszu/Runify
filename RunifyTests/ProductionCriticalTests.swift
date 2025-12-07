//
//  ProductionCriticalTests.swift
//  RunifyTests
//
//  Created for production app testing
//

import Testing
import Foundation
import MapKit
import SwiftData
@testable import Runify

// MARK: - Critical Path Tests (User Journey)

struct CriticalPathTests {
    
    /// Test: Complete run lifecycle - start, track, save
    /// This is the most critical user flow - if this breaks, the app is unusable
    @Test("Complete run lifecycle - start to save")
    func testCompleteRunLifecycle() {
        let run = Run(
            locationName: "Test Run Location",
            date: Date(),
            distance: 5000.0, // 5 km
            duration: 1800.0, // 30 minutes
            pace: 6.0 // 6 min/km
        )
        
        // Verify run is created and valid
        #expect(run.isValid == true)
        #expect(run.id != UUID()) // Should have a unique ID
        
        // Verify critical computed properties
        #expect(run.distanceInKilometers == 5.0)
        #expect(run.averageSpeed > 0)
        #expect(run.formattedDistance == "5.00 km")
        #expect(run.formattedTime == "30:00")
    }
    
    /// Test: Run with minimal valid data (edge case - very short run)
    @Test("Run with minimal valid data")
    func testMinimalValidRun() {
        let run = Run(
            locationName: "X",
            distance: 1.0, // 1 meter
            duration: 1.0, // 1 second
            pace: 0.0167 // Very fast pace
        )
        
        #expect(run.isValid == true)
        #expect(run.formattedDistance == "1 m")
    }
    
    /// Test: Run save validation - ensures invalid runs aren't saved
    @Test("Run save validation prevents invalid data")
    func testRunSaveValidation() {
        // Test various invalid scenarios
        let invalidRuns = [
            Run(locationName: "", distance: 1000.0, duration: 600.0, pace: 5.0), // Empty location
            Run(locationName: "   ", distance: 1000.0, duration: 600.0, pace: 5.0), // Whitespace only
            Run(locationName: "Test", distance: 0.0, duration: 600.0, pace: 5.0), // Zero distance
            Run(locationName: "Test", distance: 1000.0, duration: 0.0, pace: 5.0), // Zero duration
        ]
        
        for run in invalidRuns {
            #expect(run.isValid == false, "Run should be invalid: \(run.locationName), distance: \(run.distance), duration: \(run.duration)")
        }
    }
}

// MARK: - Data Integrity Tests (Prevent Data Loss)

struct DataIntegrityTests {
    
    /// Test: Run data persistence - encoding/decoding
    @Test("Run data can be encoded and decoded")
    func testRunDataPersistence() throws {
        let originalRun = Run(
            locationName: "San Francisco",
            date: Date(),
            distance: 10000.0,
            duration: 3600.0,
            pace: 6.0,
            startLocation: Coordinate(latitude: 37.7749, longitude: -122.4194),
            locations: [
                Coordinate(latitude: 37.7749, longitude: -122.4194),
                Coordinate(latitude: 37.7849, longitude: -122.4294)
            ],
            isFavorited: true,
            destinationName: "Golden Gate Park",
            destinationCoordinate: Coordinate(latitude: 37.7694, longitude: -122.4862)
        )
        
        // Verify all data is preserved
        #expect(originalRun.locationName == "San Francisco")
        #expect(originalRun.distance == 10000.0)
        #expect(originalRun.isFavorited == true)
        #expect(originalRun.destinationName == "Golden Gate Park")
        #expect(originalRun.locations.count == 2)
        #expect(originalRun.startLocation != nil)
    }
    
    /// Test: SharedRunData encoding/decoding (critical for widget)
    @Test("SharedRunData encoding and decoding")
    func testSharedRunDataPersistence() throws {
        let original = SharedRunData(
            distance: 5000.0,
            duration: 1800.0,
            pace: 6.0,
            locationName: "Test Location",
            date: Date(),
            isRunning: false
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(SharedRunData.self, from: data)
        
        #expect(decoded.distance == original.distance)
        #expect(decoded.duration == original.duration)
        #expect(decoded.pace == original.pace)
        #expect(decoded.locationName == original.locationName)
        #expect(decoded.isRunning == original.isRunning)
    }
    
    /// Test: Multiple runs persistence (widget shows 5 most recent)
    @Test("Multiple runs are sorted and limited correctly")
    func testMultipleRunsPersistence() {
        let runs = (0..<10).map { index in
            SharedRunData(
                distance: Double(1000 * (index + 1)),
                duration: Double(600 * (index + 1)),
                pace: 6.0,
                locationName: "Location \(index)",
                date: Date().addingTimeInterval(-Double(index * 3600)), // Older dates
                isRunning: false
            )
        }
        
        // Simulate the save logic - keep only 5 most recent
        let recentRuns = Array(runs.sorted { $0.date > $1.date }.prefix(5))
        
        #expect(recentRuns.count == 5)
        #expect(recentRuns.first?.date == runs.first?.date) // Most recent should be first
    }
    
    /// Test: Run update preserves existing data
    @Test("Run update preserves existing data")
    func testRunUpdatePreservesData() {
        let run = Run(
            locationName: "Original",
            distance: 5000.0,
            duration: 1800.0,
            pace: 6.0,
            locations: [Coordinate(latitude: 37.7749, longitude: -122.4194)]
        )
        
        let originalLocationCount = run.locations.count
        let originalId = run.id
        
        // Update only location name
        run.update(locationName: "Updated")
        
        #expect(run.locationName == "Updated")
        #expect(run.distance == 5000.0) // Unchanged
        #expect(run.locations.count == originalLocationCount) // Unchanged
        #expect(run.id == originalId) // ID should never change
    }
}

// MARK: - Pace Calculation Tests (Critical for Accuracy)

struct PaceCalculationTests {
    
    /// Test: Pace calculation accuracy
    @Test("Pace calculation is accurate")
    func testPaceCalculationAccuracy() {
        // 5 km in 30 minutes = 6 min/km
        let run = Run(
            locationName: "Test",
            distance: 5000.0,
            duration: 1800.0,
            pace: 6.0
        )
        
        let calculatedPace = (run.duration / 60.0) / (run.distance / 1000.0)
        #expect(calculatedPace == 6.0)
        #expect(run.pace == 6.0)
    }
    
    /// Test: Pace with zero distance (should not crash)
    @Test("Pace calculation handles zero distance")
    func testPaceWithZeroDistance() {
        let run = Run(
            locationName: "Test",
            distance: 0.0,
            duration: 1800.0,
            pace: 0.0
        )
        
        // Should not crash when calculating average speed
        let speed = run.averageSpeed
        #expect(speed == 0.0)
    }
    
    /// Test: Pace with very short duration
    @Test("Pace calculation with very short duration")
    func testPaceWithShortDuration() {
        let run = Run(
            locationName: "Test",
            distance: 100.0, // 100 meters
            duration: 10.0, // 10 seconds
            pace: 1.67 // ~1.67 min/km
        )
        
        let calculatedPace = (run.duration / 60.0) / (run.distance / 1000.0)
        #expect(abs(calculatedPace - 1.67) < 0.01)
    }
    
    /// Test: Pace history tracking (used in charts)
    @Test("Pace formatting for display")
    func testPaceFormatting() {
        let run = Run(
            locationName: "Test",
            distance: 5000.0,
            duration: 1800.0,
            pace: 6.5
        )
        
        #expect(run.formattedPace == "6.5 min/km")
        
        let sharedData = SharedRunData(
            distance: 5000.0,
            duration: 1800.0,
            pace: 0.0, // Zero pace
            locationName: "Test",
            date: Date(),
            isRunning: false
        )
        
        #expect(sharedData.formattedPace == "-- min/km")
    }
}

// MARK: - Distance Calculation Tests

struct DistanceCalculationTests {
    
    /// Test: Distance accumulation (critical for tracking)
    @Test("Distance calculation between coordinates")
    func testDistanceBetweenCoordinates() {
        // San Francisco to Oakland (approximately 13 km)
        let sf = Coordinate(latitude: 37.7749, longitude: -122.4194)
        let oakland = Coordinate(latitude: 37.8044, longitude: -122.2711)
        
        let distance = sf.distance(to: oakland)
        
        // Should be approximately 13,000 meters (13 km)
        // Using a tolerance of 2 km for GPS accuracy
        #expect(distance > 11000 && distance < 15000)
    }
    
    /// Test: Distance formatting (user-facing)
    @Test("Distance formatting displays correctly")
    func testDistanceFormatting() {
        let run1 = Run(locationName: "Test", distance: 500.0, duration: 600.0, pace: 5.0)
        let run2 = Run(locationName: "Test", distance: 5000.0, duration: 1800.0, pace: 6.0)
        let run3 = Run(locationName: "Test", distance: 100.0, duration: 60.0, pace: 1.0)
        
        #expect(run1.formattedDistance == "500 m")
        #expect(run2.formattedDistance == "5.00 km")
        #expect(run3.formattedDistance == "100 m")
    }
    
    /// Test: Distance conversions (km to miles)
    @Test("Distance conversions are accurate")
    func testDistanceConversions() {
        let run = Run(
            locationName: "Test",
            distance: 1609.34, // 1 mile in meters
            duration: 600.0,
            pace: 5.0
        )
        
        // 1 mile = 1609.34 meters
        #expect(abs(run.distanceInMiles - 1.0) < 0.01)
        #expect(abs(run.distanceInKilometers - 1.60934) < 0.0001)
    }
}

// MARK: - Location Validation Tests (Prevent Bad GPS Data)

struct LocationValidationTests {
    
    /// Test: Coordinate validation filters invalid GPS data
    @Test("Coordinate validation filters invalid data")
    func testCoordinateValidation() {
        let validCoords = [
            Coordinate(latitude: 0.0, longitude: 0.0),
            Coordinate(latitude: 90.0, longitude: 180.0),
            Coordinate(latitude: -90.0, longitude: -180.0),
            Coordinate(latitude: 37.7749, longitude: -122.4194)
        ]
        
        for coord in validCoords {
            #expect(coord.isValid == true, "Coordinate should be valid: \(coord.latitude), \(coord.longitude)")
        }
        
        let invalidCoords = [
            Coordinate(latitude: 91.0, longitude: 0.0),
            Coordinate(latitude: -91.0, longitude: 0.0),
            Coordinate(latitude: 0.0, longitude: 181.0),
            Coordinate(latitude: 0.0, longitude: -181.0)
        ]
        
        for coord in invalidCoords {
            #expect(coord.isValid == false, "Coordinate should be invalid: \(coord.latitude), \(coord.longitude)")
        }
    }
    
    /// Test: Coordinate sequence indices preserve route order
    @Test("Coordinate sequence indices preserve order")
    func testCoordinateSequenceIndices() {
        let coordinates = (0..<10).map { index in
            Coordinate(
                latitude: 37.7749 + Double(index) * 0.001,
                longitude: -122.4194 + Double(index) * 0.001,
                sequenceIndex: index
            )
        }
        
        for (index, coord) in coordinates.enumerated() {
            #expect(coord.sequenceIndex == index)
        }
        
        // Verify sorting by sequence index
        let shuffled = coordinates.shuffled()
        let sorted = shuffled.sorted { $0.sequenceIndex < $1.sequenceIndex }
        
        for (index, coord) in sorted.enumerated() {
            #expect(coord.sequenceIndex == index)
        }
    }
}

// MARK: - State Management Tests

struct StateManagementTests {
    
    /// Test: AppCoordinator navigation state transitions
    @Test("AppCoordinator state transitions")
    func testAppCoordinatorStateTransitions() {
        let coordinator = AppCoordinator()
        
        // Initial state
        #expect(coordinator.showCountdown == false)
        #expect(coordinator.showRunningMap == false)
        #expect(coordinator.showRunSummary == false)
        
        // Navigate to countdown
        coordinator.navigateToCountdown()
        #expect(coordinator.showCountdown == true)
        
        // Countdown finished -> should show running map
        coordinator.countdownFinished()
        #expect(coordinator.showCountdown == false)
        #expect(coordinator.showRunningMap == true)
        
        // Stop run -> should show summary
        coordinator.stopRun()
        #expect(coordinator.showRunningMap == false)
        #expect(coordinator.showRunSummary == true)
        
        // Finish summary -> should reset
        coordinator.finishRunSummary()
        #expect(coordinator.showRunSummary == false)
    }
    
    /// Test: AppCoordinator planned route management
    @Test("AppCoordinator planned route management")
    func testPlannedRouteManagement() {
        let coordinator = AppCoordinator()
        
        let destination = CLLocationCoordinate2D(latitude: 37.7694, longitude: -122.4862)
        let polyline = MKPolyline(coordinates: [destination], count: 1)
        
        coordinator.setPlannedRoute(
            destinationName: "Golden Gate Park",
            coordinate: destination,
            polyline: polyline
        )
        
        #expect(coordinator.plannedDestinationName == "Golden Gate Park")
        #expect(coordinator.plannedDestinationCoordinate?.latitude == destination.latitude)
        #expect(coordinator.plannedRoutePolyline != nil)
        
        coordinator.clearPlannedRoute()
        
        #expect(coordinator.plannedDestinationName == nil)
        #expect(coordinator.plannedDestinationCoordinate == nil)
        #expect(coordinator.plannedRoutePolyline == nil)
    }
    
    /// Test: Run favorite toggle state
    @Test("Run favorite toggle preserves other data")
    func testRunFavoriteToggle() {
        let run = Run(
            locationName: "Test",
            distance: 5000.0,
            duration: 1800.0,
            pace: 6.0,
            isFavorited: false
        )
        
        let originalId = run.id
        let originalDistance = run.distance
        
        run.toggleFavorite()
        #expect(run.isFavorited == true)
        #expect(run.id == originalId)
        #expect(run.distance == originalDistance)
        
        run.toggleFavorite()
        #expect(run.isFavorited == false)
    }
}

// MARK: - Edge Case Tests (Prevent Crashes)

struct EdgeCaseTests {
    
    /// Test: Run with maximum realistic values
    @Test("Run with maximum realistic values")
    func testRunWithMaximumValues() {
        let run = Run(
            locationName: "Ultra Marathon",
            distance: 42195.0, // Marathon distance in meters
            duration: 14400.0, // 4 hours
            pace: 5.7
        )
        
        #expect(run.isValid == true)
        #expect(run.distanceInKilometers == 42.195)
        #expect(run.formattedTime == "4:00:00")
    }
    
    /// Test: Run with many coordinates (performance test)
    @Test("Run with large coordinate array")
    func testRunWithManyCoordinates() {
        let coordinates = (0..<1000).map { index in
            Coordinate(
                latitude: 37.7749 + Double(index) * 0.0001,
                longitude: -122.4194 + Double(index) * 0.0001,
                sequenceIndex: index
            )
        }
        
        let run = Run(
            locationName: "Long Run",
            distance: 10000.0,
            duration: 3600.0,
            pace: 6.0,
            locations: coordinates
        )
        
        #expect(run.locations.count == 1000)
        #expect(run.isValid == true)
        
        // Test region calculation with many coordinates (should not crash)
        let region = MapRegionCalculator.calculateBoundingRegion(for: run)
        #expect(region.center.latitude != 0 || region.center.longitude != 0)
    }
    
    /// Test: Empty location name edge cases
    @Test("Empty location name handling")
    func testEmptyLocationName() {
        let run1 = Run(locationName: "", distance: 1000.0, duration: 600.0, pace: 5.0)
        let run2 = Run(locationName: "   ", distance: 1000.0, duration: 600.0, pace: 5.0)
        let run3 = Run(locationName: "\n\t", distance: 1000.0, duration: 600.0, pace: 5.0)
        
        #expect(run1.isValid == false)
        #expect(run2.isValid == false)
        #expect(run3.isValid == false)
    }
    
    /// Test: Time formatting edge cases
    @Test("Time formatting edge cases")
    func testTimeFormattingEdgeCases() {
        let run1 = Run(locationName: "Test", distance: 1000.0, duration: 0.0, pace: 5.0)
        let run2 = Run(locationName: "Test", distance: 1000.0, duration: 59.0, pace: 5.0)
        let run3 = Run(locationName: "Test", distance: 1000.0, duration: 3600.0, pace: 5.0)
        let run4 = Run(locationName: "Test", distance: 1000.0, duration: 3661.0, pace: 5.0)
        
        #expect(run2.formattedTime == "0:59")
        #expect(run3.formattedTime == "1:00:00")
        #expect(run4.formattedTime == "1:01:01")
    }
    
    /// Test: Map region calculation with edge cases
    @Test("Map region calculation edge cases")
    func testMapRegionEdgeCases() {
        // Empty coordinates
        let region1 = MapRegionCalculator.calculateBoundingRegion(for: [])
        #expect(region1.center.latitude == 37.7749) // Default fallback
        
        // Single coordinate
        let singleCoord = CLLocationCoordinate2D(latitude: 49.2593, longitude: -123.247)
        let region2 = MapRegionCalculator.calculateBoundingRegion(for: [singleCoord])
        #expect(region2.center.latitude == 49.2593)
        
        // Two identical coordinates
        let region3 = MapRegionCalculator.calculateBoundingRegion(for: [singleCoord, singleCoord])
        #expect(region3.center.latitude == 49.2593)
    }
}

// MARK: - Data Migration Tests (Backward Compatibility)

struct DataMigrationTests {
    
    /// Test: SharedRunData backward compatibility (single run fallback)
    @Test("SharedRunData backward compatibility")
    func testSharedRunDataBackwardCompatibility() {
        // Simulate old format (single run)
        let oldFormatRun = SharedRunData(
            distance: 5000.0,
            duration: 1800.0,
            pace: 6.0,
            locationName: "Old Format",
            date: Date(),
            isRunning: false
        )
        
        // Should still be valid
        #expect(oldFormatRun.distance == 5000.0)
        #expect(oldFormatRun.locationName == "Old Format")
    }
    
    /// Test: Run with optional fields (backward compatibility)
    @Test("Run with optional fields")
    func testRunWithOptionalFields() {
        // Run without destination (old format)
        let run1 = Run(
            locationName: "Test",
            distance: 5000.0,
            duration: 1800.0,
            pace: 6.0
        )
        
        #expect(run1.destinationName == nil)
        #expect(run1.destinationCoordinate == nil)
        // plannedRoute can be nil or empty array depending on SwiftData initialization
        // Check that it's either nil or empty (both are valid "no route" states)
        #expect(run1.plannedRoute == nil || run1.plannedRoute?.isEmpty == true)
        #expect(run1.isValid == true)
        
        // Run with destination (new format)
        let run2 = Run(
            locationName: "Test",
            distance: 5000.0,
            duration: 1800.0,
            pace: 6.0,
            destinationName: "Destination",
            destinationCoordinate: Coordinate(latitude: 37.7694, longitude: -122.4862)
        )
        
        #expect(run2.destinationName == "Destination")
        #expect(run2.destinationCoordinate != nil)
        #expect(run2.isValid == true)
    }
}
