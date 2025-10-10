# Runify - Personal Running Tracker

A modern iOS running tracker built with SwiftUI that automatically tracks your runs, saves your routes, and provides detailed insights into your fitness journey.

## ✨ Features

- **Real-time GPS tracking** with Core Location
- **Automatic run persistence** using Swift Data
- **Route visualization** with MapKit integration
- **Interactive dashboard** showing running statistics
- **Editable run titles** for personalization
- **Dark mode UI** with modern design
- **Automatic pace and distance calculations**

## 🚀 Getting Started

### Prerequisites
- iOS 16.0+
- Xcode 14.0+
- Swift 5.7+

### Installation
1. Clone the repository
```bash
git clone https://github.com/yourusername/runify.git
```

2. Open `Runify.xcodeproj` in Xcode
3. Build and run on your device or simulator

## 🏃‍♂️ How It Works

### Starting a Run
1. Navigate to the **Map** tab
2. Tap **Start Run** to begin tracking
3. Your location and metrics are tracked in real-time
4. Tap **Stop Run** to complete and save

### Viewing Your Runs
- **Home tab** shows recent runs and statistics
- **Tap any run card** to view details and edit titles
- **Automatic persistence** keeps your data between sessions

## ��️ Architecture

### Core Components
- **`RunTracker`** - Manages GPS tracking and run state
- **`Run` Model** - Swift Data model for run persistence
- **`HomeView`** - Dashboard with statistics and run history
- **`RunSummaryCard`** - Individual run display component

### Data Flow
```
GPS Location → RunTracker → Run Object → Swift Data → HomeView
```

### Technologies Used
- **SwiftUI** - Modern declarative UI framework
- **Swift Data** - Persistent data storage
- **Core Location** - GPS and location services
- **MapKit** - Map visualization and coordinates

## �� Screenshots



## �� Customization

### Adding New Metrics
The app automatically calculates:
- Distance (meters/kilometers)
- Duration (time elapsed)
- Pace (minutes per kilometer)

### UI Theming
- Dark mode by default
- Customizable color schemes
- Responsive design for different screen sizes

## 🐛 Troubleshooting

### Location Permissions
- Ensure location permissions are granted
- Check that location services are enabled
- Verify GPS signal strength

### Data Persistence
- Runs are automatically saved when completed
- Check console logs for debugging information
- Verify Swift Data model container setup


## �� Acknowledgments

- Built with SwiftUI and Swift Data
- GPS tracking powered by Core Location
- Map visualization using MapKit
- Inspired by the running community

---

**Runify** - Track your progress, one run at a time. 🏃‍♀️

---

*Note: This README is a template. You may want to customize it with actual screenshots, specific installation steps, or additional features unique to your implementation.*
