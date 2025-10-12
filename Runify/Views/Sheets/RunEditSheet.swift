//
//  RunEditSheet.swift
//  Runify
//
//  Created by Kellie Ho on 2025-10-10.
//

import SwiftUI

struct RunEditSheet: View {
    let run: Run
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @State private var editedTitle: String
    
    // Initialize with current title
    init(run: Run) {
        self.run = run
        self._editedTitle = State(initialValue: run.locationName)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Editable title section
                    VStack(spacing: 12) {
                        Text("Run Title")
                            .foregroundColor(colorScheme == .light ? .white : .black)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("Enter run title", text: $editedTitle)
                            .font(.title2)
                            .foregroundColor(colorScheme == .light ? .white : .black)
                            .padding(.horizontal)
                    }
                    
                    // Run date (read-only)
                    VStack(spacing: 8) {
                        Text("Date")
                            .font(.headline)
                            .foregroundColor(colorScheme == .light ? .white : .black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(run.formattedDate)
                            .font(.subheadline)
                            .foregroundColor(colorScheme == .light ? .white : .black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Edit Run")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(colorScheme == .light ? .dark : .light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)

                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveChanges()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                    }
                }
            }
        }

    }
    
    private func saveChanges() {
        // Update the run using the new update method
        run.update(locationName: editedTitle.trimmingCharacters(in: .whitespacesAndNewlines))
        
        // Save to Swift Data
        try? modelContext.save()
    }
}
