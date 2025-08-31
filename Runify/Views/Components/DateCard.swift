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
                .foregroundColor(.black)
            
            Spacer()
            
            Image(systemName: "calendar")
                .foregroundColor(.black)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.gray)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .glassEffect()
    }
}

#Preview {
    DateCard(date: Date())
        .padding()
        .background(Color(red: 0.078, green: 0.078, blue: 0.078))
}
