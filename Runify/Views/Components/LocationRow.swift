//
//  LocationRow.swift
//  Runify
//
//  Created by Kellie Ho on 2025-10-13.
//

import SwiftUI

struct LocationRow: View {
    let name: String
    let icon: String
    let distance: String?
    
    var body: some View {
        Button(action: {
            // Action will be implemented later
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    if let distance = distance {
                        Text(distance)
                            .font(.caption)
                            .foregroundColor(.secondary)
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

