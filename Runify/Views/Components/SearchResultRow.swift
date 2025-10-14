//
//  SearchResultRow.swift
//  Runify
//
//  Created by Kellie Ho on 2025-10-13.
//

import SwiftUI
import MapKit

struct SearchResultRow: View {
    let mapItem: MKMapItem
    let userLocation: CLLocationCoordinate2D?
    let action: () -> Void
    
    private var distance: String? {
        guard let userLocation = userLocation else { return nil }
        
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        let distanceInMeters = userCLLocation.distance(from: mapItem.location)
        let distanceInKm = distanceInMeters / 1000
        
        return String(format: "%.1f km", distanceInKm)
    }
    
    private var formattedAddress: String? {
        return mapItem.addressRepresentations?.fullAddress(includingRegion: true, singleLine: true)
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(mapItem.name ?? "Unknown Location")
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if let address = formattedAddress {
                        Text(address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    if let distance = distance {
                        Text(distance)
                            .font(.caption)
                            .foregroundColor(.accentColor)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
}

