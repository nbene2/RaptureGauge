# Rapture Readiness Gauge iOS App

A real-time iOS app that functions like the Doomsday Clock for biblical prophecy - tracking convergence of prophetic conditions within a rolling 100-year window.

## Features

- **Real-time Gauge**: Clock visualization showing time until "midnight" (Rapture)
- **Rolling 100-Year Window**: Automatically shifts daily, tracking active conditions
- **Weighted Scoring**: Biblical conditions weighted by theological importance
- **Category Breakdown**: Track conditions across 10 major prophetic categories
- **Historical Analysis**: View trends and acceleration over past decades
- **Push Notifications**: Alerts for significant changes and threshold breaches
- **Prediction Engine**: AI-driven analysis of convergence patterns

## How to Build and Test

### Requirements
- Xcode 15.0 or later
- iOS 15.0+ device or simulator
- macOS Ventura or later

### Build Instructions

1. **Open the project in Xcode:**
   ```bash
   cd RaptureGauge
   open RaptureGauge.xcodeproj
   ```

2. **Configure signing (Required for device testing):**
   - Select the project in navigator
   - Go to "Signing & Capabilities" tab
   - Select your Apple Developer account
   - Xcode will automatically create provisioning profile

3. **Select target device:**
   - Choose your iPhone from the device dropdown
   - Or select a simulator (iPhone 14 Pro recommended)

4. **Build and run:**
   - Press Cmd+R or click the Play button
   - App will build and launch on selected device

### Testing on Physical Device

1. Connect your iPhone via USB
2. Trust the computer when prompted
3. In Xcode, select your device from dropdown
4. Build and run (Cmd+R)
5. On first launch, go to Settings > General > Device Management and trust the developer certificate

### Testing on Simulator

1. Select a simulator from Xcode's device dropdown
2. Recommended: iPhone 14 Pro or iPhone 15
3. Build and run (Cmd+R)
4. Use Cmd+Shift+H to go home, Cmd+Left/Right to rotate

## App Structure

```
RaptureGauge/
├── Models/
│   ├── RaptureCondition.swift      # Core data models
│   └── ConditionData.swift         # Pre-populated biblical conditions
├── Views/
│   ├── MainDashboardView.swift     # Main tab navigation
│   ├── RaptureClockGauge.swift     # Clock visualization
│   ├── CategoryListView.swift      # Category breakdown
│   ├── PredictionView.swift        # Analysis and predictions
│   └── HistoryView.swift           # Historical trends
├── Services/
│   ├── RaptureCalculator.swift     # Core calculation engine
│   └── NotificationManager.swift   # Push notifications
└── RaptureGaugeApp.swift          # App entry point
```

## Current Readiness Score

The app tracks 25+ biblical conditions and calculates readiness based on:
- **Fulfilled conditions**: Israel (1948), Jerusalem (1967), Knowledge explosion
- **Emerging conditions**: Digital currency, AI, global surveillance
- **Active developments**: Geopolitical alignments, moral decline, gospel reach
- **Critical missing**: Third Temple, peace covenant, Antichrist revealed

Current calculation shows approximately **85-89% readiness** with acceleration increasing.

## Key Features Explained

### The Clock Gauge
- Shows time approaching "midnight" (100% convergence)
- Color-coded: Green (0-25%), Yellow (26-50%), Orange (51-75%), Red (76-100%)
- Updates automatically as conditions change

### Rolling Window
- Tracks conditions within past 100 years only
- Automatically shifts forward each day
- Shows why current era is unprecedented

### Category Weights
1. Israel & Jerusalem (10/10)
2. Temple Preparation (10/10)
3. Technology & Control (9/10)
4. Geopolitical (8/10)
5. Gospel Reach (8/10)
6. Natural Disasters (7/10)
7. Global Signs (7/10)
8. Moral Decline (6/10)
9. False Prophets (6/10)
10. Persecution (5/10)

## Troubleshooting

### Build Errors
- Clean build folder: Cmd+Shift+K
- Reset package caches: File > Packages > Reset Package Caches
- Delete derived data: ~/Library/Developer/Xcode/DerivedData

### Signing Issues
- Ensure you have an Apple ID configured in Xcode
- Check Bundle ID is unique: com.yourname.RaptureGauge
- Enable automatic signing in project settings

### Performance
- App optimized for iPhone 12 and later
- Best experience on iOS 16+
- Dark mode recommended for best visuals

## Privacy & Permissions
- Notifications: Optional, for condition alerts
- No internet connection required for core functionality
- No personal data collected or transmitted

## Support
For issues or questions about the biblical conditions and calculations, refer to the predictions.txt source document.