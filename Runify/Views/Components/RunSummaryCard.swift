import SwiftUI
import MapKit

struct RunSummaryCard: View {
    @EnvironmentObject var runTracker: RunTracker
    @State private var showingEditSheet = false
    let run: Run

    var body: some View {
        ZStack() {
            // Map Section (Top 2/3)
            MapSnapshotView(snapshot: nil, run: run, mapStyle: runTracker.mapStyle)
            
            // Run Data Section (Bottom 1/3)
            RunDataView(run: run)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
    let mapStyle: MapStyle

    
    var body: some View {
        ZStack {
            if let startLocation = run.startLocation {
                // Calculate region that encompasses the entire route
                let region = calculateRouteRegion()
                
                Map(position: .constant(.region(region))) {
                    // Show route if available
                    if !run.locations.isEmpty && run.locations.count > 1 {
                        let coordinates = run.locations.map { $0.clCoordinate }
                        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                        MapPolyline(polyline)
                            .stroke(.orange, lineWidth: 4)
                    }
                    
                    // Start marker
                    Marker("Start", coordinate: startLocation.clCoordinate)
                        .tint(.green)
                    
                    // End marker (last location)
                    if let lastLocation = run.locations.last {
                        Marker("Finish", coordinate: lastLocation.clCoordinate)
                            .tint(.red)
                    }
                }
                .mapStyle(mapStyle)

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
        .frame(height: 400) // Reduced height
        .clipShape(RoundedRectangle(cornerRadius: 16))

    }
    
    // MARK: - Helper Functions
    
    private func calculateRouteRegion() -> MKCoordinateRegion {
        guard !run.locations.isEmpty else {
            // Fallback to start location if no route data
            if let startLocation = run.startLocation {
                return MKCoordinateRegion(
                    center: startLocation.clCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
            // Default region if no location data
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        
        // Calculate bounds of the route
        let coordinates = run.locations.map { $0.clCoordinate }
        
        var minLat = coordinates.first?.latitude ?? 0
        var maxLat = coordinates.first?.latitude ?? 0
        var minLon = coordinates.first?.longitude ?? 0
        var maxLon = coordinates.first?.longitude ?? 0
        
        for coordinate in coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }
        
        // Calculate center and span
        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2
        let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
        
        // Add padding to the span
        let latDelta = max(maxLat - minLat, 0.001) * 1.2 // 20% padding
        let lonDelta = max(maxLon - minLon, 0.001) * 1.2 // 20% padding
        
        return MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        )
    }
}

// Run Data Section Component
struct RunDataView: View {
    let run: Run
    
    

    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Run Title and Date
            VStack(alignment: .leading, spacing: 4) {
                Text(run.locationName)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 4)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.6, alignment: .leading)
                
                Text(run.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .shadow(radius: 4)
            }
            
            // Run Metrics
            HStack(spacing: 12) {
                MetricView(label: "Distance", value: run.formattedDistance, unit: nil)
                MetricView(label: "Time", value: run.formattedTime, unit: nil)
                MetricView(label: "Pace", value: run.formattedPace, unit: nil)
            }
            
        }
        .padding(.top, 250) // Move content to bottom of card
        .padding(.leading, -20)
        .frame(maxWidth: .infinity, alignment: .center) // Center the content
   
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
                .foregroundColor(.white)
                .shadow(radius: 4)
            
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
