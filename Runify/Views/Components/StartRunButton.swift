//
//  StartRunButton.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-30.
//

import SwiftUI

struct StartRunButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                
                Text("Start Run")
            
            }
            .foregroundColor(.black)
            .padding(.horizontal, 30)
            .padding(.vertical, 16)
            .buttonStyle(.plain)
            .glassEffect(.regular.tint(.white.opacity(0.6)).interactive())
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 30) {
        StartRunButton {
            print("Start Run tapped!")
        }
        
        // Different sizes for preview
        StartRunButton {
            print("Small button tapped!")
        }
        .scaleEffect(0.8)
        
        StartRunButton {
            print("Large button tapped!")
        }
        .scaleEffect(1.2)
    }
    .padding()
    .background(Color(.systemBackground))
}
