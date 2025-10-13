//
//  DateCard.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-30.
//

import SwiftUI

struct DateCard: View {
    let date: Date
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack {
            Text(formatDate(date))
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "calendar")
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .glassEffect(.regular.tint(.clear))
    }
}

#Preview {
    DateCard(date: Date())
        .padding()
        .background(Color(.systemBackground))
}
