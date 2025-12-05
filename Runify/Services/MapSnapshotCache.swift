//
//  MapSnapshotCache.swift
//  Runify
//
//  Created for map snapshot caching
//

import Foundation
import UIKit
import MapKit
import SwiftUI
import SwiftData

/// Service for generating and caching map snapshots for run cards
class MapSnapshotCache {
    static let shared = MapSnapshotCache()
    
    // NSCache for memory caching of map snapshots
    // NSCache is thread-safe, so we can access it from any thread
    private let cache = NSCache<NSString, UIImage>()
    
    // Cache key format: "runId_mapStyle"
    private func cacheKey(for runId: UUID, mapStyle: MapStyleOption) -> String {
        return "\(runId.uuidString)_\(mapStyle.rawValue)"
    }
    
    init() {
        // Configure cache limits
        // NSCache automatically evicts least-recently-used (LRU) items when limits are reached
        // This means if you have 200 runs and view runs 1-100, then view run 101,
        // it will automatically evict the least recently viewed snapshot to make room
        // The cache intelligently keeps the most recently accessed snapshots
        cache.countLimit = 100 // Maximum 100 snapshots in memory
        cache.totalCostLimit = 100 * 1024 * 1024 // 100MB total size limit
        
        // NSCache automatically evicts when memory pressure occurs
        // No manual deletion needed - it handles eviction intelligently
    }
    
    /// Get cached snapshot or generate a new one
    /// Cache access is thread-safe (NSCache), but snapshot generation runs on background thread
    func getSnapshot(for run: Run, mapStyle: MapStyleOption, size: CGSize = CGSize(width: 300, height: 400)) async -> UIImage? {
        let key = cacheKey(for: run.id, mapStyle: mapStyle)
        
        // Check cache first (NSCache is thread-safe)
        if let cachedImage = cache.object(forKey: key as NSString) {
            return cachedImage
        }
        
        // Generate snapshot on background thread to avoid blocking UI
        let snapshot = await Task.detached(priority: .userInitiated) { [self, run, mapStyle, size] in
            return await generateSnapshot(for: run, mapStyle: mapStyle, size: size)
        }.value
        
        // Store in cache (NSCache is thread-safe)
        if let snapshot = snapshot {
            cache.setObject(snapshot, forKey: key as NSString)
        }
        
        return snapshot
    }
    
    /// Generate a map snapshot for a run (runs on background thread)
    private func generateSnapshot(for run: Run, mapStyle: MapStyleOption, size: CGSize) async -> UIImage? {
        guard run.startLocation != nil else {
            return nil
        }
        
        // Calculate region that encompasses the entire route
        let region = MapRegionCalculator.calculateRouteRegion(for: run)
        
        // Create snapshot options
        let options = MKMapSnapshotter.Options()
        options.region = region
        options.size = size
        // Use scale 2.0 for retina displays (or get from trait collection if available)
        options.scale = 2.0
        
        // Set map type based on style
        switch mapStyle {
        case .standard:
            options.mapType = .standard
        case .imagery:
            options.mapType = .satellite
        case .hybrid:
            options.mapType = .hybrid
        }
        
        let snapshotter = MKMapSnapshotter(options: options)
        
        do {
            let snapshot = try await snapshotter.start()
            // Draw route and markers on background thread
            let image = await drawRouteAndMarkers(on: snapshot, for: run)
            return image
        } catch {
            print("Failed to generate map snapshot: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Draw route and markers on the snapshot (runs on background thread)
    private func drawRouteAndMarkers(on snapshot: MKMapSnapshotter.Snapshot, for run: Run) async -> UIImage {
        let image = snapshot.image
        
        // Create graphics context
        UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return image
        }
        
        // Draw base map image
        image.draw(at: .zero)
        
        // Draw route polyline
        if !run.locations.isEmpty && run.locations.count > 1 {
            let sortedLocations = run.locations.sorted { $0.sequenceIndex < $1.sequenceIndex }
            let coordinates = sortedLocations.map { $0.clCoordinate }
            
            context.setStrokeColor(UIColor.systemOrange.cgColor)
            context.setLineWidth(4.0)
            context.setLineCap(.round)
            context.setLineJoin(.round)
            
            let path = CGMutablePath()
            var isFirst = true
            
            for coordinate in coordinates {
                let point = snapshot.point(for: coordinate)
                if isFirst {
                    path.move(to: point)
                    isFirst = false
                } else {
                    path.addLine(to: point)
                }
            }
            
            context.addPath(path)
            context.strokePath()
        }
        
        // Draw planned route (if exists)
        if let plannedRoute = run.plannedRoute, !plannedRoute.isEmpty {
            let sortedPlannedRoute = plannedRoute.sorted { $0.sequenceIndex < $1.sequenceIndex }
            let coordinates = sortedPlannedRoute.map { $0.clCoordinate }
            
            context.setStrokeColor(UIColor.systemBlue.withAlphaComponent(0.5).cgColor)
            context.setLineWidth(4.0)
            
            let path = CGMutablePath()
            var isFirst = true
            
            for coordinate in coordinates {
                let point = snapshot.point(for: coordinate)
                if isFirst {
                    path.move(to: point)
                    isFirst = false
                } else {
                    path.addLine(to: point)
                }
            }
            
            context.addPath(path)
            context.strokePath()
        }
        
        // Draw start marker (green play button icon)
        if let startLocation = run.startLocation {
            let startPoint = snapshot.point(for: startLocation.clCoordinate)
            drawIconMarker(
                at: startPoint,
                systemName: "play.circle.fill",
                color: .systemGreen,
                size: 24,
                in: context
            )
        }
        
        // Draw end marker (red checkered flag icon)
        if !run.locations.isEmpty {
            let sortedLocations = run.locations.sorted { $0.sequenceIndex < $1.sequenceIndex }
            if let lastLocation = sortedLocations.last {
                let endPoint = snapshot.point(for: lastLocation.clCoordinate)
                drawIconMarker(
                    at: endPoint,
                    systemName: "flag.checkered",
                    color: .systemRed,
                    size: 24,
                    in: context
                )
            }
        }
        
        // Draw destination marker (if exists) - red flag
        if let destination = run.destinationCoordinate {
            let destPoint = snapshot.point(for: destination.clCoordinate)
            drawIconMarker(
                at: destPoint,
                systemName: "flag.fill",
                color: .systemRed,
                size: 20,
                in: context
            )
        }
        
        // Get final image
        let finalImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        
        return finalImage
    }
    
    /// Draw an SF Symbol icon as a marker at the specified point
    /// This matches the appearance of SwiftUI Annotation views used in live Map views
    private func drawIconMarker(
        at point: CGPoint,
        systemName: String,
        color: UIColor,
        size: CGFloat,
        in context: CGContext
    ) {
        // Create configuration for SF Symbol matching SwiftUI .title2 font size
        let config = UIImage.SymbolConfiguration(pointSize: size, weight: .semibold, scale: .large)
        
        // Get the SF Symbol image
        guard let symbolImage = UIImage(systemName: systemName, withConfiguration: config) else {
            // Fallback to simple circle if symbol not available
            context.setFillColor(color.cgColor)
            context.fillEllipse(in: CGRect(x: point.x - size / 2, y: point.y - size / 2, width: size, height: size))
            return
        }
        
        // Draw white circle background (matching live Map view style: .background(.white).clipShape(Circle()))
        let backgroundSize = size * 1.3 // Slightly larger to match SwiftUI padding
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: CGRect(
            x: point.x - backgroundSize / 2,
            y: point.y - backgroundSize / 2,
            width: backgroundSize,
            height: backgroundSize
        ))
        
        // Draw icon with proper color tinting
        let iconRect = CGRect(
            x: point.x - size / 2,
            y: point.y - size / 2,
            width: size,
            height: size
        )
        
        // Render the symbol as a template and apply color using Core Graphics
        if let cgImage = symbolImage.cgImage {
            context.saveGState()
            
            // Flip coordinate system (Core Graphics has origin at bottom-left)
            context.translateBy(x: iconRect.midX, y: iconRect.midY)
            context.scaleBy(x: 1, y: -1)
            context.translateBy(x: -iconRect.midX, y: -iconRect.midY)
            
            // Clip to the symbol shape and fill with color
            context.clip(to: iconRect, mask: cgImage)
            context.setFillColor(color.cgColor)
            context.fill(iconRect)
            
            context.restoreGState()
        }
    }
    
    /// Clear cache for a specific run (useful when run is updated)
    /// NSCache is thread-safe, so this can be called from any thread
    func clearCache(for runId: UUID) {
        for style in MapStyleOption.allCases {
            let key = cacheKey(for: runId, mapStyle: style)
            cache.removeObject(forKey: key as NSString)
        }
    }
    
    /// Clear all cached snapshots
    /// NSCache is thread-safe, so this can be called from any thread
    func clearAll() {
        cache.removeAllObjects()
    }
}

