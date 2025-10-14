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
            
            // Features
            VStack(alignment: .leading, spacing: 10) {
                FeatureRow(icon: "figure.run", text: "Sync your runs with the Health app")
                FeatureRow(icon: "heart.fill", text: "Monitor your heart rate and health")
                FeatureRow(icon: "flame.fill", text: "See calories burned and steps")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "View fitness trends")
            }
            .padding(.vertical, 10)
            
            // Privacy note
            Text("Your health data is private and secure. We only access data you explicitly allow. Click \"Turn On All\" for detailed insights.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
      
            
            Spacer()
            
            // Buttons
            VStack(spacing: 12) {
                Button(action: {
                    healthKitManager.requestAuthorization { success, error in
                        dismiss()
                        
                        // Wait for sheet to dismiss before calling onAuthorize
                        if success {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                onAuthorize()
                            }
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
                
                Button("Maybe Later") {
                    dismiss()
                    
                    // Wait for sheet to dismiss before calling onAuthorize
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        onAuthorize()
                    }
                }
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .padding(.top, 40)
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
                .font(.caption)
        }
    }
}

#Preview {
    HealthKitPermissionSheet {
        print("Authorized")
    }
    .environmentObject(HealthKitManager())
}

