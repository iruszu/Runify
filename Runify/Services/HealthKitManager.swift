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
    
    // Step count data
    @Published var stepCountToday: Int = 0
    @Published var thisWeekSteps: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0]
    
    // MARK: - Initialization
    
    init() {
        checkAuthorizationStatus()
        
        // Automatically fetch step data if already authorized
        if isAuthorized {
            fetchAllStepData()
        }
    }
    
    // MARK: - Data Types
    
    private var typesToRead: Set<HKObjectType> {
        return [
            HKObjectType.workoutType(),
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.stepCount)
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
    
    func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            isAuthorized = false
            return
        }
        
        // For read permissions, HealthKit doesn't let us check authorization status reliably
        // Instead, we try to fetch data - if it works, we're authorized
        let stepType = HKQuantityType(.stepCount)
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            Task { @MainActor in
                // If we can read data, we're authorized
                if error == nil && result != nil {
                    self?.isAuthorized = true
                    self?.authorizationRequested = true
                } else {
                    // Check workout permission (write permission can be checked)
                    let workoutStatus = self?.healthStore.authorizationStatus(for: HKObjectType.workoutType())
                    self?.authorizationRequested = (workoutStatus != .notDetermined)
                    self?.isAuthorized = false
                }
            }
        }

        healthStore.execute(query)
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
                self?.checkAuthorizationStatus()
                
                // Automatically fetch step data after authorization
                if success {
                    self?.fetchAllStepData()
                }
                
                completion(success, error)
            }
        }
    }
    
    // MARK: - Save Workout

    // MARK: - Read Step Count
    
    /// Read today's step count
    func readStepCountToday() {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: stepCountType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to read step count: \(error?.localizedDescription ?? "UNKNOWN ERROR")")
                return
            }

            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            Task { @MainActor in
                self?.stepCountToday = steps
            }
        }

        healthStore.execute(query)
    }
    
    /// Read this week's step count (Sunday to Saturday)
    func readStepCountThisWeek() {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Find the start date (Sunday) of the current week
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            print("Failed to calculate the start date of the week.")
            return
        }
        
        // Find the end date (Saturday) of the current week
        guard let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) else {
            print("Failed to calculate the end date of the week.")
            return
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfWeek,
            end: endOfWeek,
            options: .strictStartDate
        )
        
        let query = HKStatisticsCollectionQuery(
            quantityType: stepCountType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startOfWeek,
            intervalComponents: DateComponents(day: 1)
        )
        
        query.initialResultsHandler = { [weak self] _, result, error in
            guard let result = result else {
                if let error = error {
                    print("An error occurred while retrieving step count: \(error.localizedDescription)")
                }
                return
            }

            result.enumerateStatistics(from: startOfWeek, to: endOfWeek) { statistics, _ in
                if let quantity = statistics.sumQuantity() {
                    let steps = Int(quantity.doubleValue(for: HKUnit.count()))
                    let day = calendar.component(.weekday, from: statistics.startDate)
                    Task { @MainActor in
                        self?.thisWeekSteps[day] = steps
                    }
                }
            }
        }

        healthStore.execute(query)
    }
    
    /// Fetch all step count data (today + this week)
    func fetchAllStepData() {
        readStepCountToday()
        readStepCountThisWeek()
    }
}
