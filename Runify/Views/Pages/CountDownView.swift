//
//  CountDownView.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-18.
//

import SwiftUI

struct CountDownView: View {
    @EnvironmentObject var runTracker: RunTracker
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var countdownTimer = TimerManager()
    @State var countdown: Int = 3
    
    var body: some View {
        Text("\(countdown)")
            .font(.system(size: 256, weight: .regular, design: .default))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.blue)
            .foregroundColor(.white)
            .onAppear {
                startCountdown()
            }
            .onDisappear {
                countdownTimer.stopTimer()
            }
    }
    
    func startCountdown() {
        countdownTimer.startTimer(interval: 1.0, repeats: true) {
            if countdown > 1 {
                countdown -= 1
            } else {
                countdownTimer.stopTimer()
                // Use coordinator for navigation
                runTracker.startRun()
                coordinator.countdownFinished()
            }
        }
    }
}

#Preview {
    CountDownView()
        .environmentObject(RunTracker())
}
