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
    @State private var countdown: Int = 3
    @State private var progress: CGFloat = 1.0
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    private let totalCountdown: Int = 3
    private let ringSize: CGFloat = 280
    private let ringLineWidth: CGFloat = 16
    
    var body: some View {
        GlassEffectContainer {
            ZStack {
                // Clean minimal background
                Color.clear
                    .ignoresSafeArea()
                
                ZStack {
                    // Background ring (track) - minimal and clean
                    Circle()
                        .stroke(
                            Color.white.opacity(0.15),
                            style: StrokeStyle(
                                lineWidth: ringLineWidth,
                                lineCap: .round
                            )
                        )
                        .frame(width: ringSize, height: ringSize)
                    
                    // Animated progress ring - clean modern style
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [.accentColor, .accentColor.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(
                                lineWidth: ringLineWidth,
                                lineCap: .round
                            )
                        )
                        .frame(width: ringSize, height: ringSize)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6, dampingFraction: 0.75), value: progress)
                    
                    // Inner liquid glass container with countdown number
                    ZStack {
                        // Countdown number - clean and minimal
                        Text("\(countdown)")
                            .font(.system(size: 120, weight: .thin, design: .rounded))
                            .foregroundStyle(.white)
                            .scaleEffect(scale)
                            .opacity(opacity)
                    }
                    .frame(width: ringSize - 80, height: ringSize - 80)
            
                }
            }
        }
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
                // Smooth modern animation - fade out
                withAnimation(.easeInOut(duration: 0.25)) {
                    scale = 0.85
                    opacity = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    countdown -= 1
                    updateProgress()
                    
                    // Smooth modern animation - fade in with subtle bounce
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        scale = 1.0
                        opacity = 1
                    }
                }
            } else {
                // Final smooth animation before starting run
                withAnimation(.easeInOut(duration: 0.4)) {
                    scale = 1.2
                    opacity = 0
                    progress = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    countdownTimer.stopTimer()
                    
                    // Transfer planned route data from coordinator to runTracker
                    if let polyline = coordinator.plannedRoutePolyline,
                       let destinationName = coordinator.plannedDestinationName,
                       let destinationCoordinate = coordinator.plannedDestinationCoordinate {
                        runTracker.setPlannedRoute(
                            destinationName: destinationName,
                            coordinate: destinationCoordinate,
                            polyline: polyline
                        )
                    }
                    
                    // Use coordinator for navigation
                    runTracker.startRun()
                    coordinator.countdownFinished()
                }
            }
        }
    }
    
    func updateProgress() {
        let remainingProgress = CGFloat(countdown) / CGFloat(totalCountdown)
        progress = remainingProgress
    }
}

#Preview {
    CountDownView()
        .environmentObject(RunTracker())
        .environmentObject(AppCoordinator())
}
