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
    @EnvironmentObject var runTracker: RunTracker
    @State private var selectedStyle: MapStyleOption = .standard
    
    enum MapStyleOption: String, CaseIterable {
        case standard = "Standard"
        case imagery = "Imagery"
        case hybrid = "Hybrid"
        
        var mapStyle: MapStyle {
            switch self {
            case .standard:
                return .standard
            case .imagery:
                return .imagery
            case .hybrid:
                return .hybrid
            }
        }
        
        var description: String {
            switch self {
            case .standard:
                return "Classic road map with labels"
            case .imagery:
                return "Satellite imagery view"
            case .hybrid:
                return "Satellite with road labels"
            }
        }
        
        var icon: String {
            switch self {
            case .standard:
                return "map"
            case .imagery:
                return "globe"
            case .hybrid:
                return "map.fill"
            }
        }
    }
    
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
                        }
                    }
                    
                    // Apply button
                    Button(action: {
                        runTracker.mapStyle = selectedStyle.mapStyle
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "checkmark")
                                .font(.headline)
                            Text("Apply Style")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .presentationDetents([.fraction(0.7)])
        .presentationDragIndicator(.hidden)
        .onAppear {
            // Set initial selection based on current map style
            selectedStyle = getCurrentMapStyle(from: runTracker.mapStyle)
        }
    }
    
    // Helper function to determine current map style
    private func getCurrentMapStyle(from mapStyle: MapStyle) -> MapStyleOption {
        // Since MapStyle doesn't conform to Equatable, we'll use a different approach
        // We'll compare the string representation of the map style
        let mapStyleString = String(describing: mapStyle)
        
        if mapStyleString.contains("standard") {
            return .standard
        } else if mapStyleString.contains("imagery") {
            return .imagery
        } else if mapStyleString.contains("hybrid") {
            return .hybrid
        } else {
            return .standard // Default fallback
        }
    }
}

// Map Style Card Component
struct MapStyleCard: View {
    let style: MapSelectionSheet.MapStyleOption
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
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
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.title3)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
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

#Preview {
    MapSelectionSheet()
        .environmentObject(RunTracker())
}
