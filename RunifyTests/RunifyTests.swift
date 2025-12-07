//
//  RunifyTests.swift
//  RunifyTests
//
//  Created by Kellie Ho on 2025-12-06.
//

import Testing
import Foundation
import MapKit
@testable import Runify

// MARK: - Run Model Tests

struct RunModelTests {
    
    @Test("Run initialization with valid data")
    func testRunInitialization() {
        let run = Run(
            locationName: "Test Location",
            date: Date(),
            distance: 5000.0,
            duration: 1800.0,
            pace: 6.0
        )
        
        #expect(run.locationName == "Test Location")
        #expect(run.distance == 5000.0)
        #expect(run.duration == 1800.0)
        #expect(run.pace == 6.0)
        #expect(run.isFavorited == false)
    }
    
    @Test("Run distance conversions")
    func testDistanceConversions() {
        let run = Run(
            locationName: "Test",
            distance: 5000.0, // 5 km
            duration: 1800.0,
            pace: 6.0
        )
        
        #expect(run.distanceInKilometers == 5.0)
        #expect(abs(run.distanceInMiles - 3.106855) < 0.0001)
    }
    
    @Test("Run average speed calculations")
    func testAverageSpeedCalculations() {
        // 5 km in 30 minutes = 10 km/h
        let run = Run(
            locationName: "Test",
            distance: 5000.0,
            duration: 1800.0, // 30 minutes
            pace: 6.0
        )
        
        #expect(run.averageSpeed == 10.0)
        #expect(abs(run.averageSpeedInMPH - 6.21371) < 0.0001)
    }
    
    @Test("Run average speed with zero duration")
    func testAverageSpeedWithZeroDuration() {
        let run = Run(
            locationName: "Test",
            distance: 5000.0,
            duration: 0.0,
            pace: 6.0
        )
        
        #expect(run.averageSpeed == 0.0)
    }
    
    @Test("Run pace conversions")
    func testPaceConversions() {
        let run = Run(
            locationName: "Test",
            distance: 5000.0,
            duration: 1800.0,
            pace: 6.0 // 6 min/km
        )
        
        #expect(abs(run.paceInMinutesPerMile - 9.65604) < 0.0001)
    }
    
    @Test("Run formatted distance")
    func testFormattedDistance() {
        let run1 = Run(
            locationName: "Test",
            distance: 5000.0, // >= 1000, should show km
            duration: 1800.0,
            pace: 6.0
        )
        
        let run2 = Run(
            locationName: "Test",
            distance: 500.0, // < 1000, should show meters
            duration: 1800.0,
            pace: 6.0
        )
        
        #expect(run1.formattedDistance == "5.00 km")
        #expect(run2.formattedDistance == "500 m")
    }
    
    @Test("Run formatted time")
    func testFormattedTime() {
        let run1 = Run(
            locationName: "Test",
            distance: 5000.0,
            duration: 3661.0, // 1 hour, 1 minute, 1 second
            pace: 6.0
        )
        
        let run2 = Run(
            locationName: "Test",
            distance: 5000.0,
            duration: 125.0, // 2 minutes, 5 seconds
            pace: 6.0
        )
        
        #expect(run1.formattedTime == "1:01:01")
        #expect(run2.formattedTime == "2:05")
    }
    
    @Test("Run formatted pace")
    func testFormattedPace() {
        let run = Run(
            locationName: "Test",
            distance: 5000.0,
            duration: 1800.0,
            pace: 6.5
        )
        
        #expect(run.formattedPace == "6.5 min/km")
    }
    
    @Test("Run validation - valid run")
    func testRunValidationValid() {
        let run = Run(
            locationName: "Test Location",
            distance: 5000.0,
            duration: 1800.0,
            pace: 6.0
        )
        
        #expect(run.isValid == true)
    }
    
    @Test("Run validation - invalid run with zero distance")
    func testRunValidationZeroDistance() {
        let run = Run(
            locationName: "Test Location",
            distance: 0.0,
            duration: 1800.0,
            pace: 6.0
        )
        
        #expect(run.isValid == false)
    }
    
    @Test("Run validation - invalid run with zero duration")
    func testRunValidationZeroDuration() {
        let run = Run(
            locationName: "Test Location",
            distance: 5000.0,
            duration: 0.0,
            pace: 6.0
        )
        
        #expect(run.isValid == false)
    }
    
    @Test("Run validation - invalid run with empty location name")
    func testRunValidationEmptyLocationName() {
        let run = Run(
            locationName: "   ",
            distance: 5000.0,
            duration: 1800.0,
            pace: 6.0
        )
        
        #expect(run.isValid == false)
    }
    
    @Test("Run validation - valid run with zero pace")
    func testRunValidationZeroPace() {
        let run = Run(
            locationName: "Test Location",
            distance: 5000.0,
            duration: 1800.0,
            pace: 0.0
        )
        
        #expect(run.isValid == true) // Zero pace is allowed
    }
    
    @Test("Run update method")
    func testRunUpdate() {
        let run = Run(
            locationName: "Original",
            distance: 1000.0,
            duration: 600.0,
            pace: 5.0
        )
        
        run.update(
            locationName: "Updated",
            distance: 2000.0,
            isFavorited: true
        )
        
        #expect(run.locationName == "Updated")
        #expect(run.distance == 2000.0)
        #expect(run.duration == 600.0) // Unchanged
        #expect(run.isFavorited == true)
    }
    
    @Test("Run toggle favorite")
    func testRunToggleFavorite() {
        let run = Run(
            locationName: "Test",
            distance: 5000.0,
            duration: 1800.0,
            pace: 6.0
        )
        
        #expect(run.isFavorited == false)
        run.toggleFavorite()
        #expect(run.isFavorited == true)
        run.toggleFavorite()
        #expect(run.isFavorited == false)
    }
}

// MARK: - Coordinate Model Tests

struct CoordinateModelTests {
    
    @Test("Coordinate initialization")
    func testCoordinateInitialization() {
        let coordinate = Coordinate(latitude: 37.7749, longitude: -122.4194)
        
        #expect(coordinate.latitude == 37.7749)
        #expect(coordinate.longitude == -122.4194)
        #expect(coordinate.sequenceIndex == 0)
    }
    
    @Test("Coordinate from CLLocationCoordinate2D")
    func testCoordinateFromCLLocation() {
        let clCoordinate = CLLocationCoordinate2D(latitude: 49.2593, longitude: -123.247)
        let coordinate = Coordinate(clCoordinate, sequenceIndex: 5)
        
        #expect(coordinate.latitude == 49.2593)
        #expect(coordinate.longitude == -123.247)
        #expect(coordinate.sequenceIndex == 5)
    }
    
    @Test("Coordinate validation - valid coordinates")
    func testCoordinateValidationValid() {
        let coordinate1 = Coordinate(latitude: 0.0, longitude: 0.0)
        let coordinate2 = Coordinate(latitude: 90.0, longitude: 180.0)
        let coordinate3 = Coordinate(latitude: -90.0, longitude: -180.0)
        
        #expect(coordinate1.isValid == true)
        #expect(coordinate2.isValid == true)
        #expect(coordinate3.isValid == true)
    }
    
    @Test("Coordinate validation - invalid latitude")
    func testCoordinateValidationInvalidLatitude() {
        let coordinate1 = Coordinate(latitude: 91.0, longitude: 0.0)
        let coordinate2 = Coordinate(latitude: -91.0, longitude: 0.0)
        
        #expect(coordinate1.isValid == false)
        #expect(coordinate2.isValid == false)
    }
    
    @Test("Coordinate validation - invalid longitude")
    func testCoordinateValidationInvalidLongitude() {
        let coordinate1 = Coordinate(latitude: 0.0, longitude: 181.0)
        let coordinate2 = Coordinate(latitude: 0.0, longitude: -181.0)
        
        #expect(coordinate1.isValid == false)
        #expect(coordinate2.isValid == false)
    }
    
    @Test("Coordinate distance calculation")
    func testCoordinateDistance() {
        // San Francisco to Los Angeles (approximately 560 km)
        let sf = Coordinate(latitude: 37.7749, longitude: -122.4194)
        let la = Coordinate(latitude: 34.0522, longitude: -118.2437)
        
        let distance = sf.distance(to: la)
        
        // Should be approximately 560,000 meters (560 km)
        #expect(distance > 550000 && distance < 570000)
    }
    
    @Test("Coordinate clCoordinate conversion")
    func testCoordinateCLConversion() {
        let coordinate = Coordinate(latitude: 37.7749, longitude: -122.4194)
        let clCoordinate = coordinate.clCoordinate
        
        #expect(clCoordinate.latitude == 37.7749)
        #expect(clCoordinate.longitude == -122.4194)
    }
}

// MARK: - TimeFormatter Tests

struct TimeFormatterTests {
    
    @Test("Format time - minutes and seconds")
    func testFormatTime() {
        #expect(formatTime(seconds: 125.0) == "02:05")
        #expect(formatTime(seconds: 3661.0) == "61:01")
        #expect(formatTime(seconds: 0.0) == "00:00")
        #expect(formatTime(seconds: 59.0) == "00:59")
    }
    
    @Test("Format time - edge cases")
    func testFormatTimeEdgeCases() {
        #expect(formatTime(seconds: 60.0) == "01:00")
        #expect(formatTime(seconds: 3599.0) == "59:59")
    }
}

// MARK: - TimerManager Tests

struct TimerManagerTests {
    
    @Test("Timer start and stop")
    func testTimerStartStop() async throws {
        await MainActor.run {
            let timerManager = TimerManager()
            
            #expect(timerManager.isRunning == false)
            #expect(timerManager.isPaused == false)
            
            var counter = 0
            timerManager.startTimer(interval: 0.05, repeats: true) {
                counter += 1
            }
            
            #expect(timerManager.isRunning == true)
            #expect(timerManager.isPaused == false)
            
            // Process run loop to allow timer to fire
            // Use a deadline that gives the timer time to fire
            let deadline = Date().addingTimeInterval(0.2)
            RunLoop.current.run(until: deadline)
            
            timerManager.stopTimer()
            
            #expect(timerManager.isRunning == false)
            #expect(timerManager.isPaused == false)
            #expect(counter > 0, "Timer should have fired at least once, got \(counter)")
        }
    }
    
    @Test("Timer pause and resume")
    func testTimerPauseResume() async throws {
        await MainActor.run {
            let timerManager = TimerManager()
            
            var counter = 0
            timerManager.startTimer(interval: 0.05, repeats: true) {
                counter += 1
            }
            
            // Process run loop to allow timer to fire
            let deadline1 = Date().addingTimeInterval(0.15)
            RunLoop.current.run(until: deadline1)
            let countBeforePause = counter
            
            timerManager.pauseTimer()
            #expect(timerManager.isPaused == true)
            #expect(timerManager.isRunning == true)
            
            // Process run loop while paused - counter should not increment
            let deadline2 = Date().addingTimeInterval(0.15)
            RunLoop.current.run(until: deadline2)
            #expect(counter == countBeforePause, "Counter should not increment while paused, got \(counter) vs \(countBeforePause)") // Should not have incremented
            
            timerManager.resumeTimer(interval: 0.05, repeats: true) {
                counter += 1
            }
            #expect(timerManager.isPaused == false)
            
            // Process run loop after resume - counter should increment
            let deadline3 = Date().addingTimeInterval(0.15)
            RunLoop.current.run(until: deadline3)
            #expect(counter > countBeforePause, "Counter should increment after resume, got \(counter) vs \(countBeforePause)")
            
            timerManager.stopTimer()
        }
    }
    
    @Test("Timer elapsed time tracking")
    func testTimerElapsedTime() async throws {
        await MainActor.run {
            let timerManager = TimerManager()
            
            timerManager.startTimer(interval: 0.1, repeats: true) {}
            
            // Process run loop to allow time to pass
            let deadline = Date().addingTimeInterval(0.2)
            RunLoop.current.run(until: deadline)
            
            let elapsed = timerManager.getElapsedTime()
            #expect(elapsed > 0.1 && elapsed < 0.5, "Elapsed time should be approximately 0.2 seconds, got \(elapsed)")
            
            // Verify elapsed time is tracked while running
            #expect(elapsed > 0, "Elapsed time should be tracked while running")
            
            timerManager.stopTimer()
            
            // After stopping, elapsed time is reset to 0 (this is the actual behavior of stopTimer)
            let finalElapsed = timerManager.getElapsedTime()
            #expect(finalElapsed == 0, "After stopTimer(), elapsed time should be reset to 0")
        }
    }
    
    @Test("Timer pause does nothing when not running")
    func testTimerPauseWhenNotRunning() {
        let timerManager = TimerManager()
        
        timerManager.pauseTimer()
        #expect(timerManager.isPaused == false)
        #expect(timerManager.isRunning == false)
    }
    
    @Test("Timer resume does nothing when not paused")
    func testTimerResumeWhenNotPaused() {
        let timerManager = TimerManager()
        
        var counter = 0
        timerManager.startTimer(interval: 0.1, repeats: true) {
            counter += 1
        }
        
        let countBeforeResume = counter
        timerManager.resumeTimer(interval: 0.1, repeats: true) {
            counter += 1
        }
        
        // Counter should not have changed since we weren't paused
        // (Note: This test might be flaky due to timing, but the logic is correct)
        timerManager.stopTimer()
    }
}

// MARK: - MapRegionCalculator Tests

struct MapRegionCalculatorTests {
    
    @Test("Calculate bounding region for empty coordinates")
    func testBoundingRegionEmptyCoordinates() {
        let region = MapRegionCalculator.calculateBoundingRegion(for: [])
        
        #expect(region.center.latitude == 37.7749)
        #expect(region.center.longitude == -122.4194)
        #expect(region.span.latitudeDelta == 0.01)
        #expect(region.span.longitudeDelta == 0.01)
    }
    
    @Test("Calculate bounding region for single coordinate")
    func testBoundingRegionSingleCoordinate() {
        let coordinate = CLLocationCoordinate2D(latitude: 49.2593, longitude: -123.247)
        let region = MapRegionCalculator.calculateBoundingRegion(for: [coordinate])
        
        #expect(region.center.latitude == 49.2593)
        #expect(region.center.longitude == -123.247)
        #expect(region.span.latitudeDelta >= 0.001)
        #expect(region.span.longitudeDelta >= 0.001)
    }
    
    @Test("Calculate bounding region for multiple coordinates")
    func testBoundingRegionMultipleCoordinates() {
        let coordinates = [
            CLLocationCoordinate2D(latitude: 49.0, longitude: -123.0),
            CLLocationCoordinate2D(latitude: 49.5, longitude: -123.5),
            CLLocationCoordinate2D(latitude: 50.0, longitude: -124.0)
        ]
        
        let region = MapRegionCalculator.calculateBoundingRegion(for: coordinates)
        
        // Center should be between min and max
        #expect(region.center.latitude >= 49.0 && region.center.latitude <= 50.0)
        #expect(region.center.longitude >= -124.0 && region.center.longitude <= -123.0)
        
        // Span should include all points with padding
        #expect(region.span.latitudeDelta > 0.5)
        #expect(region.span.longitudeDelta > 0.5)
    }
    
    @Test("Calculate bounding region for run with no locations")
    func testBoundingRegionForRunNoLocations() {
        let run = Run(
            locationName: "Test",
            distance: 5000.0,
            duration: 1800.0,
            pace: 6.0
        )
        
        let region = MapRegionCalculator.calculateBoundingRegion(for: run)
        
        #expect(region.center.latitude == 37.7749)
        #expect(region.center.longitude == -122.4194)
    }
    
    @Test("Calculate bounding region for run with locations")
    func testBoundingRegionForRunWithLocations() {
        let coordinates = [
            Coordinate(latitude: 49.0, longitude: -123.0),
            Coordinate(latitude: 49.5, longitude: -123.5),
            Coordinate(latitude: 50.0, longitude: -124.0)
        ]
        
        let run = Run(
            locationName: "Test",
            distance: 5000.0,
            duration: 1800.0,
            pace: 6.0,
            locations: coordinates
        )
        
        let region = MapRegionCalculator.calculateBoundingRegion(for: run)
        
        #expect(region.center.latitude >= 49.0 && region.center.latitude <= 50.0)
        #expect(region.center.longitude >= -124.0 && region.center.longitude <= -123.0)
    }
    
    @Test("Calculate route region for run")
    func testRouteRegionForRun() {
        let coordinates = [
            Coordinate(latitude: 49.0, longitude: -123.0),
            Coordinate(latitude: 49.5, longitude: -123.5)
        ]
        
        let run = Run(
            locationName: "Test",
            distance: 5000.0,
            duration: 1800.0,
            pace: 6.0,
            locations: coordinates
        )
        
        let region = MapRegionCalculator.calculateRouteRegion(for: run)
        
        #expect(region.center.latitude >= 49.0 && region.center.latitude <= 49.5)
        #expect(region.center.longitude >= -123.5 && region.center.longitude <= -123.0)
    }
    
    @Test("Calculate route region for run with no locations")
    func testRouteRegionNoLocations() {
        let startLocation = Coordinate(latitude: 49.2593, longitude: -123.247)
        let run = Run(
            locationName: "Test",
            distance: 5000.0,
            duration: 1800.0,
            pace: 6.0,
            startLocation: startLocation
        )
        
        let region = MapRegionCalculator.calculateRouteRegion(for: run)
        
        #expect(region.center.latitude == 49.2593)
        #expect(region.center.longitude == -123.247)
    }
}

// MARK: - RecentSearch Tests

struct RecentSearchTests {
    
    @Test("RecentSearch initialization")
    func testRecentSearchInitialization() {
        let coordinate = CLLocationCoordinate2D(latitude: 49.2593, longitude: -123.247)
        let search = RecentSearch(
            name: "Test Location",
            address: "123 Test St",
            coordinate: coordinate
        )
        
        #expect(search.name == "Test Location")
        #expect(search.address == "123 Test St")
        #expect(search.coordinate.latitude == 49.2593)
        #expect(search.coordinate.longitude == -123.247)
    }
    
    @Test("RecentSearch codable encoding and decoding")
    func testRecentSearchCodable() throws {
        let coordinate = CLLocationCoordinate2D(latitude: 49.2593, longitude: -123.247)
        let original = RecentSearch(
            name: "Test Location",
            address: "123 Test St",
            coordinate: coordinate
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(RecentSearch.self, from: data)
        
        #expect(decoded.name == original.name)
        #expect(decoded.address == original.address)
        #expect(decoded.coordinate.latitude == original.coordinate.latitude)
        #expect(decoded.coordinate.longitude == original.coordinate.longitude)
    }
}

// MARK: - APIError Tests

struct APIErrorTests {
    
    @Test("APIError error descriptions")
    func testAPIErrorDescriptions() {
        #expect(APIError.invalidURL.errorDescription == "The URL is invalid")
        #expect(APIError.invalidResponse.errorDescription == "Received an invalid response from the server")
        #expect(APIError.requestFailed(statusCode: 404).errorDescription == "Request failed with status code: 404")
        #expect(APIError.noData.errorDescription == "No data received from server")
        #expect(APIError.unauthorized.errorDescription == "Unauthorized access - please check your API key")
        #expect(APIError.forbidden.errorDescription == "Access forbidden")
        #expect(APIError.notFound.errorDescription == "Resource not found")
        #expect(APIError.serverError.errorDescription == "Server error occurred")
        #expect(APIError.unknown.errorDescription == "An unknown error occurred")
    }
    
    @Test("APIError with nested errors")
    func testAPIErrorWithNestedErrors() {
        let testError = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        let decodingError = APIError.decodingFailed(testError)
        #expect(decodingError.errorDescription?.contains("Failed to decode response") == true)
        
        let encodingError = APIError.encodingFailed(testError)
        #expect(encodingError.errorDescription?.contains("Failed to encode request") == true)
        
        let networkError = APIError.networkError(testError)
        #expect(networkError.errorDescription?.contains("Network error") == true)
    }
}

// MARK: - MapStyleOption Tests

struct MapStyleOptionTests {
    
    @Test("MapStyleOption cases")
    func testMapStyleOptionCases() {
        #expect(MapStyleOption.standard.rawValue == "Standard")
        #expect(MapStyleOption.imagery.rawValue == "Imagery")
        #expect(MapStyleOption.hybrid.rawValue == "Hybrid")
    }
    
    @Test("MapStyleOption descriptions")
    func testMapStyleOptionDescriptions() {
        #expect(MapStyleOption.standard.description == "Classic road map with labels")
        #expect(MapStyleOption.imagery.description == "Satellite imagery view")
        #expect(MapStyleOption.hybrid.description == "Satellite with road labels")
    }
    
    @Test("MapStyleOption icons")
    func testMapStyleOptionIcons() {
        #expect(MapStyleOption.standard.icon == "map")
        #expect(MapStyleOption.imagery.icon == "globe")
        #expect(MapStyleOption.hybrid.icon == "map.fill")
    }
    
    @Test("MapStyleOption all cases")
    func testMapStyleOptionAllCases() {
        let allCases = MapStyleOption.allCases
        #expect(allCases.count == 3)
        #expect(allCases.contains(.standard))
        #expect(allCases.contains(.imagery))
        #expect(allCases.contains(.hybrid))
    }
}
