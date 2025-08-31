import SwiftUI
import MapKit

struct RunSummaryCard: View {
    let run: Run

    var body: some View {
        ZStack() {
            // Map Section (Top 2/3)
            MapSnapshotView(snapshot: nil, run: run)
            
            // Run Data Section (Bottom 1/3)
            RunDataView(run: run)
        }
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .shadow(radius: 8)
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
        .frame(height: 580) // Adjust based on your needs
        .clipShape(RoundedRectangle(cornerRadius: 16))

    }
}

// Run Data Section Component
struct RunDataView: View {
    let run: Run
    
    private func formatDistance(_ distance: Double) -> String {
        if distance >= 1000 {
            // Convert to kilometers for distances >= 1km
            let km = distance / 1000
            return String(format: "%.2f", km)
        } else {
            // Show meters for distances < 1km
            return String(format: "%.0f", distance)
        }
    }
    

    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
            HStack(spacing: 20) {
                MetricView(label: "Distance", value: formatDistance(run.distance), unit: run.distance >= 1000 ? "km" : "m")
                MetricView(label: "Time", value: run.formattedTime, unit: nil)
                MetricView(label: "Pace", value: String(format: "%.1f", run.pace), unit: "min/km")
            }
            
        }
        .padding(.top, 410) // Adjust to overlap on map
        .frame(maxWidth: .infinity, alignment: .leading) // Make it take full width and align left
        .padding(.leading, 20) // Add left padding to move content away from edge
   
    }
}

struct MetricView: View {
    let label: String
    let value: String
    let unit: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) { // Changed from default center to .leading
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
        .background(Color.black)
}
