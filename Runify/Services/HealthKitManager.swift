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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("HealthKit: Initial authorization check complete. Authorized: \(self.isAuthorized)")
            if self.isAuthorized {
                self.fetchAllStepData()
            }
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
            DispatchQueue.main.async {
                self.isAuthorized = false
                self.authorizationRequested = false
            }
            return
        }
        
        // Check write permissions first (these can be checked reliably)
        let workoutStatus = healthStore.authorizationStatus(for: HKObjectType.workoutType())
        
        // If workout permission is not determined, we haven't requested authorization yet
        if workoutStatus == .notDetermined {
            DispatchQueue.main.async {
                self.authorizationRequested = false
                self.isAuthorized = false
            }
            return
        }
        
        // Mark that we've requested authorization before
        DispatchQueue.main.async {
            self.authorizationRequested = true
        }
        
        // For read permissions, use a different approach - try to query any data at all
        let stepType = HKQuantityType(.stepCount)
        
        // Create a broader date range to increase chances of finding some data
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: endDate) ?? endDate
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        
        let query = HKSampleQuery(
            sampleType: stepType,
            predicate: predicate,
            limit: 1,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { [weak self] _, samples, error in
            DispatchQueue.main.async {
                if let error = error {
                    let nsError = error as NSError
                    
                    // Check for authorization-related errors
                    if nsError.domain == "com.apple.healthkit" && nsError.code == 5 {
                        // HKErrorAuthorizationDenied
                        print("HealthKit: Authorization denied")
                        self?.isAuthorized = false
                    } else if nsError.domain == "com.apple.healthkit" && nsError.code == 6 {
                        // HKErrorAuthorizationNotDetermined  
                        print("HealthKit: Authorization not determined")
                        self?.isAuthorized = false
                    } else {
                        // For other errors (including "no data"), assume we have permission
                        print("HealthKit: Query completed (may have no data, but authorized)")
                        self?.isAuthorized = true
                    }
                } else {
                    // Query succeeded (with or without data), we have permission
                    print("HealthKit: Query succeeded, authorized")
                    self?.isAuthorized = true
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    /// Force refresh authorization status - useful when returning from Settings
    func refreshAuthorizationStatus() {
        print("HealthKit: Refreshing authorization status...")
        checkAuthorizationStatus()
        
        // Also try to fetch data to verify permissions
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            print("HealthKit: Current authorization status: \(self?.isAuthorized ?? false)")
            if self?.isAuthorized == true {
                print("HealthKit: Fetching step data...")
                self?.fetchAllStepData()
            }
        }
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
                // Don't treat "no data available" as an error - just set steps to 0
                if let error = error {
                    print("Step count query (today): \(error.localizedDescription)")
                }
                Task { @MainActor in
                    self?.stepCountToday = 0
                }
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
                    print("Weekly step count query: \(error.localizedDescription)")
                }
                // Set all days to 0 if no data available
                Task { @MainActor in
                    self?.thisWeekSteps = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0]
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
