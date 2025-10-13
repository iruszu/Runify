//
//  RecentSearchRow.swift
//  Runify
//
//  Created by Kellie Ho on 2025-10-13.
//

import SwiftUI

struct RecentSearchRow: View {
    let name: String
    let address: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "clock")
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if !address.isEmpty {
                        Text(address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
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

