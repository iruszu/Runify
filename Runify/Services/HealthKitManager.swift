//
//  HealthKitManager.swift
//  Runify
//
//  Created by Kellie Ho on 2025-10-13.
//

import Foundation
import HealthKit
import Observation

@Observable
class HealthKitManager {
    let healthStore = HKHealthStore()
    
    var isAuthorized = false
    var authorizationRequested = false
    
    // Step count data
    var stepCountToday: Int = 0
    var thisWeekSteps: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0]
    
    // Calorie data
    var caloriesToday: Int = 0
    var thisWeekCalories: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0]
    
    // Activity rings data
    var activitySummary: HKActivitySummary?
    
    // Current heart rate during workout
    var currentHeartRate: Int? = nil
    
    // MARK: - Initialization
    
    init() {
        checkAuthorizationStatus()
        
        // Automatically fetch step data if already authorized
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            print("HealthKit: Initial authorization check complete. Authorized: \(self.isAuthorized)")
            if self.isAuthorized {
                self.fetchAllStepData()
                self.fetchAllCalorieData()
                self.fetchTodayActivitySummary()
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
            HKQuantityType(.stepCount),
            HKObjectType.activitySummaryType()
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
            Task { @MainActor in
                self.isAuthorized = false
                self.authorizationRequested = false
            }
            return
        }
        
        // Check write permissions first (these can be checked reliably)
        let workoutStatus = healthStore.authorizationStatus(for: HKObjectType.workoutType())
        
        // If workout permission is not determined, we haven't requested authorization yet
        if workoutStatus == .notDetermined {
            Task { @MainActor in
                self.authorizationRequested = false
                self.isAuthorized = false
            }
            return
        }
        
        // Mark that we've requested authorization before
        Task { @MainActor in
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
            Task { @MainActor in
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
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            print("HealthKit: Current authorization status: \(self?.isAuthorized ?? false)")
            if self?.isAuthorized == true {
                print("HealthKit: Fetching health data...")
                // These functions use callbacks and execute asynchronously
                // They can be called in parallel since they're independent
                self?.fetchAllStepData()
                self?.fetchAllCalorieData()
                self?.fetchTodayActivitySummary()
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
            Task { @MainActor in
                self?.authorizationRequested = true
                self?.checkAuthorizationStatus()
                
                // Automatically fetch health data after authorization
                // These execute asynchronously via callbacks, so they run concurrently
                if success {
                    self?.fetchAllStepData()
                    self?.fetchAllCalorieData()
                    self?.fetchTodayActivitySummary()
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
    
    /// Fetch all calorie data (today + this week)
    func fetchAllCalorieData() {
        fetchTodayCalories()
        readCaloriesThisWeek()
    }
    
    /// Read today's calories burned
    func fetchTodayCalories() {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
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
            quantityType: calorieType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                if let error = error {
                    print("Calorie query (today): \(error.localizedDescription)")
                }
                Task { @MainActor in
                    self?.caloriesToday = 0
                }
                return
            }

            let calories = Int(sum.doubleValue(for: HKUnit.kilocalorie()))
            Task { @MainActor in
                self?.caloriesToday = calories
            }
        }

        healthStore.execute(query)
    }
    
    /// Read this week's calories burned (Sunday to Saturday)
    func readCaloriesThisWeek() {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
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
            quantityType: calorieType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startOfWeek,
            intervalComponents: DateComponents(day: 1)
        )
        
        query.initialResultsHandler = { [weak self] _, result, error in
            guard let result = result else {
                if let error = error {
                    print("Weekly calorie query: \(error.localizedDescription)")
                }
                // Set all days to 0 if no data available
                Task { @MainActor in
                    self?.thisWeekCalories = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0]
                }
                return
            }

            result.enumerateStatistics(from: startOfWeek, to: endOfWeek) { statistics, _ in
                if let quantity = statistics.sumQuantity() {
                    let calories = Int(quantity.doubleValue(for: HKUnit.kilocalorie()))
                    let day = calendar.component(.weekday, from: statistics.startDate)
                    Task { @MainActor in
                        self?.thisWeekCalories[day] = calories
                    }
                }
            }
        }

        healthStore.execute(query)
    }
    
    // MARK: - Activity Summary
    
    /// Fetch today's activity summary for activity rings
    func fetchTodayActivitySummary() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let predicate = HKQuery.predicateForActivitySummary(with: DateComponents(
            calendar: calendar,
            year: calendar.component(.year, from: today),
            month: calendar.component(.month, from: today),
            day: calendar.component(.day, from: today)
        ))
        
        let query = HKActivitySummaryQuery(predicate: predicate) { [weak self] _, summaries, error in
            guard let summaries = summaries, let todaysSummary = summaries.first else {
                if let error = error {
                    print("Activity summary query: \(error.localizedDescription)")
                }
                Task { @MainActor in
                    self?.activitySummary = nil
                }
                return
            }
            
            Task { @MainActor in
                self?.activitySummary = todaysSummary
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Heart Rate
    
    /// Fetch current heart rate (most recent reading)
    func fetchCurrentHeartRate(completion: @escaping (Int?) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion(nil)
            return
        }
        
        // Get the most recent heart rate sample (within last 30 seconds)
        let now = Date()
        let startDate = now.addingTimeInterval(-30)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: now,
            options: .strictEndDate
        )
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: predicate,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            guard let sample = samples?.first as? HKQuantitySample else {
                if let error = error {
                    print("Heart rate query error: \(error.localizedDescription)")
                }
                completion(nil)
                return
            }
            
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let heartRate = Int(sample.quantity.doubleValue(for: heartRateUnit))
            completion(heartRate)
        }
        
        healthStore.execute(query)
    }
}
