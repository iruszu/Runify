//
//  POISection.swift
//  Runify
//
//  Created by Kellie Ho on 2025-10-13.
//

import SwiftUI
import MapKit

struct POISection: View {
    let title: String
    let icon: String
    let items: [MKMapItem]
    let userLocation: CLLocationCoordinate2D?
    let onSelectItem: (MKMapItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(items.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            
            ForEach(items.prefix(10), id: \.self) { item in
                SearchResultRow(
                    mapItem: item,
                    userLocation: userLocation
                ) {
                    onSelectItem(item)
                }
            }
            
            if items.count > 10 {
                Text("+ \(items.count - 10) more")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
            }
        }
    }
}

