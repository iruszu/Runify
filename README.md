# Runify

A native iOS running tracker built with SwiftUI. Tracks GPS routes, integrates with HealthKit, and provides real-time updates via Live Activities and Dynamic Island.

![Runify Screenshots](screenshots.png)

## Technical Stack

### Core Frameworks
- **SwiftUI** - Declarative UI framework for all views
- **SwiftData** - Persistent storage for run history and routes
- **Core Location** - GPS tracking with background location updates
- **MapKit** - Route visualization and map rendering
- **ActivityKit** - Live Activities for Lock Screen and Dynamic Island
- **WidgetKit** - Home screen widgets and Control Center controls
- **HealthKit** - Integration with Apple Health for calories, heart rate, and activity rings

### Architecture
- **MVVM pattern** with `@Observable` macro (iOS 17+)
- **Coordinator pattern** for navigation state management
- **Service layer** for HealthKit, map snapshots, and Live Activities
- **App Groups** for data sharing between main app and widget extension

### Key Components

**ViewModels:**
- `RunTracker` - Manages GPS tracking, distance calculation, pace computation
- `AppCoordinator` - Handles navigation flow and planned route state
- `SearchViewModel` - Google Maps Places API integration for location search

**Services:**
- `HealthKitManager` - Reads/writes workout data, activity summaries
- `LiveActivityManager` - ActivityKit lifecycle (start/update/end)
- `MapSnapshotCache` - Generates and caches map thumbnails for run cards
- `SharedRunData` - App Group UserDefaults for widget data sharing

**Models:**
- `Run` - SwiftData model with distance, duration, pace, route coordinates
- `Coordinate` - SwiftData model for storing GPS points with sequence indices

## Features

### Real-Time Tracking
- GPS tracking with `kCLLocationAccuracyBest` for precise route recording
- Background location updates during runs (When In Use + background mode)
- Distance calculation using `CLLocation.distance(from:)`
- Pace computation: `(elapsedTime / 60) / (distance / 1000)` in min/km
- Location validation filters out stale/cached GPS readings

### Live Activities & Dynamic Island
- Lock Screen Live Activity showing distance, pace, time, and location
- Dynamic Island support (iPhone 14 Pro+) with compact, minimal, and expanded states
- SwiftChart integration for pace trend visualization
- Interactive pause/stop buttons via App Intents
- Orange color scheme throughout for brand consistency

### Widgets
- Home screen widget displaying recent run stats
- Control Center widget for quick start/stop
- Updates every 15 minutes via timeline provider
- Shares data with main app via App Group UserDefaults

### HealthKit Integration
- Reads active energy burned (calories)
- Writes workout sessions with distance, duration, pace
- Fetches activity rings data for Health tab
- Background delivery for step count and calories
- Privacy-first: only accesses explicitly authorized data

### Map Features
- Three map styles: Standard, Imagery, Hybrid
- Route planning with MKDirections for destination-based runs
- Map snapshot caching with NSCache for performance
- Background route calculation (non-blocking UI)
- Reverse geocoding for location names

### Data Persistence
- SwiftData for run history with automatic persistence
- Coordinate arrays stored with sequence indices for route reconstruction
- Planned route data (destination + polyline) saved with runs
- Favorite runs support

## Design Decisions

### UI/UX
- **Dark mode only** - Consistent dark theme throughout
- **Orange accent color** - Primary brand color (#FF6B35 or similar)
- **Minimal navigation** - Tab-based with full-screen covers for run flow
- **Non-blocking operations** - Route calculation happens in background, run starts immediately
- **Location retry logic** - Graceful handling when GPS isn't immediately available

### Performance
- Map snapshot generation on background thread using `Task.detached`
- NSCache for map thumbnails (thread-safe, automatic memory management)
- Pace history limited to last 20 readings for chart performance
- Location updates filtered by distance (5m minimum) to reduce noise

### Architecture Choices
- **Observable macro** instead of Combine for reactive state (iOS 17+)
- **App Groups** for widget data sharing (not direct SwiftData access)
- **NotificationCenter** for widget-to-app communication (pause/stop actions)
- **Separate widget extension** target for modularity
- **Coordinator pattern** to avoid navigation state in views

### Location Tracking
- Uses `authorizedWhenInUse` + `allowsBackgroundLocationUpdates` (Apple's recommended approach)
- `distanceFilter: 10m` for battery optimization
- `activityType: .fitness` for better GPS accuracy during runs
- Location validation: filters readings older than 60s and too close together

## Project Structure

```
Runify/
├── App/              # App entry point
├── Models/           # SwiftData models (Run, Coordinate)
├── ViewModels/       # Business logic (RunTracker, AppCoordinator)
├── Views/            # SwiftUI views
│   ├── Pages/        # Main screens
│   ├── Sheets/        # Modal presentations
│   └── Components/   # Reusable UI components
├── Services/         # HealthKit, Live Activities, Map caching
├── Network/          # Google Maps Places API integration
└── Utilities/        # Helpers (TimerManager, TimeFormatter)

RunifyWidget/
├── RunifyWidget.swift           # Home screen widget
├── RunifyWidgetLiveActivity.swift  # Lock Screen + Dynamic Island
├── RunifyWidgetControl.swift    # Control Center widget
└── SharedRunData.swift          # App Group data sharing
```

## Setup

### Requirements
- iOS 26.0+ (uses latest SwiftUI features)
- Xcode 15.0+
- Apple Developer account (for App Groups and Live Activities)

### Configuration
1. **App Groups**: Create `group.com.kellieho.Runify` in Apple Developer Portal
2. **Google Maps API**: Add your API key to `Info.plist` under `GOOGLE_MAPS_API_KEY`
3. **HealthKit**: Enable in Capabilities, add usage descriptions to Info.plist
4. **Live Activities**: `NSSupportsLiveActivities = YES` in both app and widget Info.plist

### Build
```bash
# Clone and open in Xcode
open Runify.xcodeproj

# Build for device (Live Activities require physical device)
# Simulator doesn't support Live Activities or Dynamic Island
```

## Known Limitations

- Live Activities only work on physical devices (not simulator)
- Dynamic Island requires iPhone 14 Pro or later
- App Group must be configured in Apple Developer Portal
- Route calculation requires network connection (Google Maps API)

## License

Private project - not for distribution.
