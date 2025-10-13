//
//  HealthKitManager.swift
//  Runify
//
//  Created by Kellie Ho on 2025-10-13.
//

import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    @Published var isAuthorized = false
    @Published var authorizationRequested = false
    
    // MARK: - Initialization
    
    init() {
        checkAuthorization()
    }
    
    // MARK: - Data Types
    
    private var typesToRead: Set<HKObjectType> {
        return [
            HKObjectType.workoutType(),
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceWalkingRunning)
        ]
    }
    
    private var typesToWrite: Set<HKSampleType> {
        return [
            HKObjectType.workoutType(),
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceWalkingRunning)
        ]
    }
    
    // MARK: - Authorization
    
    private func checkAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            isAuthorized = false
            return
        }
        
        // Check if we have at least workout permission
        let status = healthStore.authorizationStatus(for: HKObjectType.workoutType())
        isAuthorized = (status == .sharingAuthorized)
        authorizationRequested = (status != .notDetermined)
    }
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "HealthKit", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        healthStore.requestAuthorization(
            toShare: typesToWrite,
            read: typesToRead
        ) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.authorizationRequested = true
                self?.checkAuthorization()
                completion(success, error)
            }
        }
    }
    
    // MARK: - Save Workout
    
    func saveWorkout(
        startDate: Date,
        endDate: Date,
        distance: Double, // in meters
        calories: Double,
        heartRateSamples: [(Date, Double)] = [],
        completion: @escaping (Bool, Error?) -> Void
    ) {
        guard isAuthorized else {
            completion(false, NSError(domain: "HealthKit", code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Not authorized to write to HealthKit"]))
            return
        }
        
        // Create workout
        let workout = HKWorkout(
            activityType: .running,
            start: startDate,
            end: endDate,
            duration: endDate.timeIntervalSince(startDate),
            totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: calories),
            totalDistance: HKQuantity(unit: .meter(), doubleValue: distance),
            metadata: nil
        )
        
        // Save workout
        healthStore.save(workout) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
}
