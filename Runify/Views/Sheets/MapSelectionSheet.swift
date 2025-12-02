//
//  MapSelectionSheet.swift
//  Runify
//
//  Created by Kellie Ho on 2025-10-10.
//

import SwiftUI
import MapKit

struct MapSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(RunTracker.self) private var runTracker
    @State private var selectedStyle: MapStyleOption = .standard
    
    // MapStyleOption enum is now defined in RunTracker.swift
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle area
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.secondary)
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 20)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    Text("Choose Map Style")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.bottom, 8)
                    
                    ForEach(MapStyleOption.allCases, id: \.self) { style in
                        MapStyleCard(
                            style: style,
                            isSelected: selectedStyle == style
                        ) {
                            selectedStyle = style
                            // Immediately update the map style when selected
                            runTracker.mapStyle = style.mapStyle
                            runTracker.mapStyleOption = style
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .presentationDetents([.fraction(0.7)])
        .presentationDragIndicator(.hidden)
        .onAppear {
            // Set initial selection based on current map style option
            selectedStyle = runTracker.mapStyleOption
        }
    }
    
}

// Map Style Card Component
struct MapStyleCard: View {
    let style: MapStyleOption
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                onTap()
            }
        }) {
            VStack(spacing: 12) {
                // Map preview
                MapPreviewView(mapStyle: style.mapStyle)
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Style info
                HStack(spacing: 12) {
                    Image(systemName: style.icon)
                        .font(.title2)
                        .foregroundColor(.accentColor)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(style.rawValue)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(style.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .accentColor : .secondary)
                        .font(.title3)
                        .animation(.easeInOut(duration: 0.2), value: isSelected)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// Map Preview Component
struct MapPreviewView: View {
    let mapStyle: MapStyle
    
    var body: some View {
        Map(position: .constant(.region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // San Francisco
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )))) {
            // Add some sample annotations to show the style
            Annotation("Sample", coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)) {
                Image(systemName: "location.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
        }
        .mapStyle(mapStyle)
        .disabled(true) // Disable interaction for preview
    }
}

