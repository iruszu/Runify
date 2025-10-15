//
//  HealthView.swift
//  Runify
//
//  Created by Kellie Ho on 2025-10-13.
//

import SwiftUI

struct HealthView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if healthKitManager.isAuthorized {
                        // Show health data
                        VStack(spacing: 20) {
                            // Today's Steps Card
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "figure.walk")
                                        .font(.title2)
                                        .foregroundColor(.accentColor)
                                    Text("Today's Steps")
                                        .font(.headline)
                                    Spacer()
                                    Button(action: {
                                        healthKitManager.fetchAllStepData()
                                    }) {
                                        Image(systemName: "arrow.clockwise")
                                            .foregroundColor(.accentColor)
                                    }
                                }
                                
                                Text("\(healthKitManager.stepCountToday)")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text("steps")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                            
                            // Weekly Steps Card
                            VStack(alignment: .leading, spacing: 12) {
                                Text("This Week")
                                    .font(.headline)
                                
                                VStack(spacing: 12) {
                                    ForEach(Array(weekDays.enumerated()), id: \.offset) { index, day in
                                        HStack {
                                            Text(day)
                                                .font(.subheadline)
                                                .frame(width: 50, alignment: .leading)
                                            
                                            GeometryReader { geometry in
                                                ZStack(alignment: .leading) {
                                                    // Background bar
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color(.systemGray5))
                                                        .frame(height: 8)
                                                    
                                                    // Progress bar
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color.accentColor)
                                                        .frame(
                                                            width: geometry.size.width * progress(for: index + 1),
                                                            height: 8
                                                        )
                                                }
                                            }
                                            .frame(height: 8)
                                            
                                            Text("\(healthKitManager.thisWeekSteps[index + 1] ?? 0)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .frame(width: 60, alignment: .trailing)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                    } else {
                        VStack(spacing: 24) {

                            HStack {
                                Image("Runify")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .padding()
                             
                                Image(systemName: "xmark")
                                
                                
                                // Icon
                                Image("AppleHealth")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .padding()
                                
                          
                            }
                            
                            
                            // Title
                            HStack {
                                Text("Connect to")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text("Apple Health")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.pink)
                            }
                            
                            
                            // Description
                            Text("Track your runs and monitor your fitness progress")
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.top, -10)

                            
                            // Buttons
                            VStack(spacing: 12) {

                                
                                if !healthKitManager.authorizationRequested {
                                    // First time - show Connect button
                                    // Features
                                    VStack(alignment: .leading, spacing: 10) {
                                        FeatureRow(icon: "figure.run", text: "Sync your runs with the Health app")
                                        FeatureRow(icon: "heart.fill", text: "Monitor your heart rate and health")
                                        FeatureRow(icon: "flame.fill", text: "See calories burned and steps")
                                        FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "View fitness trends")
                                    }
                                    .padding(.vertical, 10)
                                    Button(action: {
                                        healthKitManager.requestAuthorization { success, error in
                                            // After authorization, fetch data if successful
                                            if success {
                                                healthKitManager.fetchAllStepData()
                                            }
                                        }
                                    }) {
                                        Text("Connect")
                                            .fontWeight(.semibold)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                            .glassEffect(.regular.tint(.accentColor).interactive())
                                        
                                    }
                                } else {
                                    // Previously requested - show Settings button + instructions
                                    VStack(spacing: 10) {
                                        // Instructions Card
                                        VStack(alignment: .leading, spacing: 12) {
                                            HStack {
                                                Image(systemName: "info.circle.fill")
                                                    .foregroundColor(.accentColor)
                                                Text("Enable Health Permissions")
                                                    .font(.headline)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 8) {
                                                InstructionStep(number: "1", text: "Open the Health app")
                                                InstructionStep(number: "2", text: "Tap your profile icon (top right)")
                                                InstructionStep(number: "3", text: "Scroll to 'Apps' and tap 'Runify'")
                                                InstructionStep(number: "4", text: "Turn on all data categories")
                                            }
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                        
                                        // Open Settings Button
                                        Button(action: {
                                            if let url = URL(string: "x-apple-health://") {
                                                UIApplication.shared.open(url)
                                            }
                                        }) {
                                            HStack {
                                                Image(systemName: "heart.text.square.fill")
                                                Text("Open Health App")
                                                    .fontWeight(.semibold)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                            .glassEffect(.regular.tint(.accentColor).interactive())
                                            
                                        }
                                        .padding(30)
                                        
                                        // Manual refresh button
                                        Button(action: {
                                            healthKitManager.refreshAuthorizationStatus()
                                        }) {
                                            HStack {
                                                Image(systemName: "arrow.clockwise")
                                                Text("Check Again")
                                                    .fontWeight(.medium)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .foregroundColor(.accentColor)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(12)
                                        }
                                        
                                        
                                        
                                    }
                                }
                                
                                
                                // Privacy note
                                Text("Your health data is private and secure. We only access data you explicitly allow. Click \"Turn On All\" for detailed insights.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                          
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .padding(.top, 20)
                    }
                }
            }
            .navigationTitle("Health")
            .onAppear {
                // Re-check authorization status in case it changed in Settings
                healthKitManager.checkAuthorizationStatus()
                
                // Fetch data if already authorized
                if healthKitManager.isAuthorized {
                    healthKitManager.fetchAllStepData()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                // Refresh authorization when app becomes active (user might have changed permissions in Settings)
                healthKitManager.refreshAuthorizationStatus()
            }
        }
    }
    
    // Helper to get weekday names
    private var weekDays: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols
    }
    
    // Calculate progress bar width (0.0 to 1.0)
    private func progress(for day: Int) -> CGFloat {
        let steps = healthKitManager.thisWeekSteps[day] ?? 0
        let maxSteps = healthKitManager.thisWeekSteps.values.max() ?? 1
        return maxSteps > 0 ? CGFloat(steps) / CGFloat(maxSteps) : 0
    }
}

// MARK: - Supporting Views

struct InstructionStep: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.accentColor)
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    HealthView()
        .environmentObject(HealthKitManager())
}

