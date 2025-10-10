import SwiftUI
import MapKit

struct RunSummaryCard: View {
    @State private var showingEditSheet = false
    let run: Run

    var body: some View {
        ZStack() {
            // Map Section (Top 2/3)
            MapSnapshotView(snapshot: nil, run: run)
            
            // Run Data Section (Bottom 1/3)
            RunDataView(run: run)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 8)
        .onTapGesture {
            showingEditSheet = true
        }
        .sheet(isPresented: $showingEditSheet) {
            RunEditSheet(run: run)
                .presentationDetents([.fraction(0.3)]) // Adjust the height as needed
                .preferredColorScheme(.dark)
        }
        
    }
}

struct RunEditSheet: View {
    let run: Run
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
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
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("Enter run title", text: $editedTitle)
                            .font(.title2)
                            .padding(.horizontal)
                    }
                    
                    // Run date (read-only)
                    VStack(spacing: 8) {
                        Text("Date")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(run.formattedDate)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Edit Run")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                    .disabled(editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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



struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// Map Section Component
struct MapSnapshotView: View {
    let snapshot: UIImage?
    let run: Run

    
    var body: some View {
        ZStack {
            if let startLocation = run.startLocation {
                Map(position: .constant(.region(MKCoordinateRegion(
                    center: startLocation.clCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )))) {
                    Marker("Start", coordinate: startLocation.clCoordinate)
                        .tint(.green)
                }

                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
            }
            
            // Inner shadow overlay
            VStack {
                Spacer()
                
                // Bottom inner shadow
                 LinearGradient(
                     gradient: Gradient(stops: [
                         .init(color: Color.clear, location: 0.0),
                         .init(color: Color.clear, location: 0.5), // Adjust this to control spread
                         .init(color: Color.black.opacity(0.9), location: 1.0)
                     ]),
                     startPoint: .top,
                     endPoint: .bottom
                 )
                 .frame(height: 600)
                 .blendMode(.multiply)
            }
        }
        .frame(height: 450) // Adjusted height
        .clipShape(RoundedRectangle(cornerRadius: 16))

    }
}

// Run Data Section Component
struct RunDataView: View {
    let run: Run
    
    

    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Run Title and Date
            VStack(alignment: .leading, spacing: 4) {
                Text(run.locationName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(run.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Run Metrics
            HStack(spacing: 15) {
                MetricView(label: "Distance", value: run.formattedDistance, unit: nil)
                MetricView(label: "Time", value: run.formattedTime, unit: nil)
                MetricView(label: "Pace", value: run.formattedPace, unit: nil)
            }
            
        }
        .padding(.top, 250) // Reduced overlap for shorter card
        .frame(maxWidth: .infinity, alignment: .center) // Center the content
        .padding(.horizontal, 20) // Add horizontal padding for better spacing
   
    }
}

struct MetricView: View {
    let label: String
    let value: String
    let unit: String?
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) { // Center align the metrics
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value + (unit != nil ? " \(unit!)" : ""))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
        }
    }
}

#Preview {
    // Sample data for preview
    let sampleRun = Run(
        locationName: "Sample Run",
        date: Date(),
        distance: 1000,
        duration: 500,
        pace: 5.270,
        startLocation: Coordinate(latitude: 49.2593, longitude: -123.247)
    )
    
    RunSummaryCard(run: sampleRun)
        .padding()
        .background(Color(.systemBackground))
}
