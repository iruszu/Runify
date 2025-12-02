import SwiftUI
import MapKit

struct RunSummaryCard: View {
    @Environment(RunTracker.self) private var runTracker
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditSheet = false
    let run: Run

    var body: some View {
        ZStack {
            MapSnapshotView(snapshot: nil, run: run, mapStyle: runTracker.mapStyle)
            RunDataView(run: run)
                .padding(.top, 200)
                .offset(x: 20, y: 20)
    

        }
        .overlay(alignment: .topTrailing) {
            // Heart button for favoriting
            Button {
                run.toggleFavorite()
                try? modelContext.save()
            } label: {
                Image(systemName: run.isFavorited ? "heart.fill" : "heart")
                    .font(.system(size: 25))
                   .foregroundColor(run.isFavorited ? .red : .white)
                    .padding(20)
                    .symbolEffect(.bounce, value: run.isFavorited)
                    
            }
           
        }
        .onTapGesture {
                showingEditSheet = true
        }
        .sheet(isPresented: $showingEditSheet) {
            RunEditSheet(run: run)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled)
                .presentationCornerRadius(20)
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
                    // Show planned route (if exists) - semi-transparent blue
                    if let plannedRoute = run.plannedRoute, !plannedRoute.isEmpty {
                        // Sort by sequence index to ensure correct order
                        let sortedPlannedRoute = plannedRoute.sorted { $0.sequenceIndex < $1.sequenceIndex }
                        let coordinates = sortedPlannedRoute.map { $0.clCoordinate }
                        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                        MapPolyline(polyline)
                            .stroke(.blue.opacity(0.5), lineWidth: 4)
                    }
                    
                    // Show actual route - solid orange with smooth rendering
                    if !run.locations.isEmpty && run.locations.count > 1 {
                        // Sort by sequence index to ensure correct order (prevents zig-zags)
                        let sortedLocations = run.locations.sorted { $0.sequenceIndex < $1.sequenceIndex }
                        let coordinates = sortedLocations.map { $0.clCoordinate }
                        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                        MapPolyline(polyline)
                            .stroke(.orange, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    }
                    
                    // Show destination marker (if exists)
                    if let destination = run.destinationCoordinate {
                        Annotation(run.destinationName ?? "Destination", coordinate: destination.clCoordinate) {
                            ZStack {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 20, height: 20)
                                Image(systemName: "flag.fill")
                                    .foregroundColor(.white)
                                    .font(.caption2)
                            }
                        }
                    }
                    
                    // Start marker
                    Marker("Start", coordinate: startLocation.clCoordinate)
                        .tint(.green)
                    
                    // End marker (last location in route)
                    if !run.locations.isEmpty {
                        let sortedLocations = run.locations.sorted { $0.sequenceIndex < $1.sequenceIndex }
                        if let lastLocation = sortedLocations.last {
                            Annotation("Finish", coordinate: lastLocation.clCoordinate) {
                                Image(systemName: "flag.checkered")
                                    .foregroundColor(.red)
                                    .font(.title2)
                                    .background(.white)
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
                .interactiveDismissDisabled(true)
                .disabled(true) // Make map non-interactive (display only)
                .mapStyle(mapStyle)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
            }

            VStack {
                Spacer()
                
                // Bottom inner shadow
                 LinearGradient(
                     gradient: Gradient(stops: [
                         .init(color: Color.clear, location: 0.0),
                         .init(color: Color.clear, location: 0.2), // Adjust this to control spread
                         .init(color: Color.black.opacity(0.7), location: 0.6)
                     ]),
                     startPoint: .top,
                     endPoint: .bottom
                 )
                 .frame(height: 300)
                
                 .blendMode(.multiply)
            }
        }
        .frame(width: 300, height: 400) // Reduced height
        .cornerRadius(16)



    }
    
    // MARK: - Helper Functions
    
    private func calculateRouteRegion() -> MKCoordinateRegion {
        return MapRegionCalculator.calculateRouteRegion(for: run)
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
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 4)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
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
        .frame(width: 300, height: 100)
   
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
                .font(.subheadline)
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
