//
//  HealthKitPermissionSheet.swift
//  Runify
//
//  Created by Kellie Ho on 2025-10-13.
//

import SwiftUI

struct HealthKitPermissionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var healthKitManager: HealthKitManager
    let onAuthorize: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Handle area
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.secondary)
                .frame(width: 36, height: 5)
                .padding(.top, 8)
            
            Spacer()
            
            // Icon
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundColor(.red)
                .padding(.bottom, 8)
            
            // Title
            Text("Connect to Apple Health")
                .font(.title)
                .fontWeight(.bold)
            
            // Description
            Text("Track your runs and monitor your fitness progress")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            // Features
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "figure.run", text: "Track your runs automatically")
                FeatureRow(icon: "heart.fill", text: "Monitor your heart rate")
                FeatureRow(icon: "flame.fill", text: "See calories burned")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "View fitness trends")
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 32)
            
            // Privacy note
            Text("Your health data is private and secure. We only access data you explicitly allow.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            // Buttons
            VStack(spacing: 12) {
                Button(action: {
                    healthKitManager.requestAuthorization { success, error in
                        if success {
                            onAuthorize()
                        }
                        dismiss()
                    }
                }) {
                    Text("Connect to Health")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Button("Maybe Later") {
                    onAuthorize() // Still allow them to start run
                    dismiss()
                }
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 30)
                .font(.title3)
            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    HealthKitPermissionSheet {
        print("Authorized")
    }
    .environmentObject(HealthKitManager())
}

