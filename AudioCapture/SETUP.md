# AudioCapture - Setup & Build Instructions

This guide will help you build and run AudioCapture on your Mac.

## Prerequisites

- macOS 12.3 (Monterey) or later
- Xcode 14.0 or later
- Swift 5.9 or later

## Quick Start

### Method 1: Open in Xcode (Recommended)

Since this is a Swift package with app sources, you can open it directly in Xcode:

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/AudioCapture.git
   cd AudioCapture
   ```

2. **Open in Xcode**
   ```bash
   open Package.swift
   ```

   Or double-click `Package.swift` in Finder.

3. **Configure the project**
   - Select the `AudioCapture` scheme
   - Choose your Mac as the run destination
   - Build the project (⌘B)

4. **Run the app**
   - Click Run (⌘R)
   - Grant Screen Recording permission when prompted

### Method 2: Create Xcode Project

If you prefer a traditional Xcode project structure:

1. **Create a new macOS App project in Xcode**
   - Open Xcode
   - File > New > Project
   - Choose macOS > App
   - Name: `AudioCapture`
   - Interface: SwiftUI
   - Language: Swift
   - Minimum Deployment: macOS 12.3

2. **Copy source files**
   ```bash
   # Copy all Swift files to your new project
   cp -r AudioCapture/Sources/* YourXcodeProject/AudioCapture/
   ```

3. **Configure entitlements**

   Add to your `AudioCapture.entitlements`:
   ```xml
   <key>com.apple.security.device.audio-input</key>
   <true/>
   <key>com.apple.security.device.camera</key>
   <true/>
   ```

4. **Update Info.plist**

   Add the following usage description:
   ```xml
   <key>NSScreenCaptureDescription</key>
   <string>AudioCapture needs screen recording permission to capture system audio.</string>
   ```

5. **Build and run**

## Building for Distribution

### Code Signing

1. **Select your Development Team**
   - In Xcode, select the project
   - Go to Signing & Capabilities
   - Select your development team

2. **Configure Bundle Identifier**
   - Use a unique bundle identifier (e.g., `com.yourname.AudioCapture`)

### Creating a Release Build

1. **Archive the app**
   ```
   Product > Archive
   ```

2. **Export the app**
   - Click "Distribute App"
   - Choose "Copy App"
   - Save the exported app

### Notarization (for public distribution)

For distributing outside the App Store, you'll need to notarize the app:

```bash
# Create a signed archive
xcodebuild archive \
  -scheme AudioCapture \
  -archivePath AudioCapture.xcarchive

# Export for notarization
xcodebuild -exportArchive \
  -archivePath AudioCapture.xcarchive \
  -exportPath AudioCapture \
  -exportOptionsPlist ExportOptions.plist

# Submit for notarization
xcrun notarytool submit AudioCapture.zip \
  --apple-id "your@email.com" \
  --team-id "TEAM_ID" \
  --password "app-specific-password"
```

## Development

### Project Structure

```
AudioCapture/
├── Package.swift                      # Swift Package definition
├── AudioCapture/
│   └── Sources/
│       ├── AudioCapture/
│       │   └── AudioCaptureApp.swift  # App entry point
│       ├── Views/
│       │   └── ContentView.swift      # Main UI
│       └── Services/
│           ├── SystemAudioRecorder.swift
│           └── AudioFileWriter.swift
├── LICENSE                            # GPL-3.0
└── README.md
```

### Adding New Features

1. Create a new branch
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes
3. Test thoroughly
4. Submit a pull request

### Common Build Issues

#### Issue: "AudioCapture is not signed"

**Solution**:
- Xcode > Signing & Capabilities
- Select your development team
- Or disable code signing for development:
  - Build Settings > Code Signing Identity > Don't Code Sign

#### Issue: "Screen Recording permission denied"

**Solution**:
- System Settings > Privacy & Security > Screen Recording
- Enable AudioCapture
- Restart the app

#### Issue: "Cannot find 'SCStream' in scope"

**Solution**:
- Ensure your deployment target is macOS 12.3 or later
- Clean build folder (⌘⇧K)
- Rebuild (⌘B)

## Testing

Currently, the app should be tested manually:

1. **Permission flow**
   - First launch should request Screen Recording permission
   - Verify permission prompt appears

2. **Recording functionality**
   - Start recording
   - Play system audio (music, video, etc.)
   - Stop recording
   - Verify file is saved to `~/Music/AudioCapture Recordings/`

3. **Audio quality**
   - Open recorded file in QuickTime or another audio player
   - Verify audio quality and stereo channels

4. **UI responsiveness**
   - Check timer updates during recording
   - Verify audio level meter animates
   - Test button states

## Debugging

### Enable verbose logging

Add this to `SystemAudioRecorder.swift`:

```swift
#if DEBUG
print("Debug: \(message)")
#endif
```

### Check ScreenCaptureKit availability

```swift
if #available(macOS 12.3, *) {
    // ScreenCaptureKit available
} else {
    // Show error
}
```

## Performance

AudioCapture is designed to be lightweight:

- **CPU Usage**: < 5% during recording
- **Memory**: ~50-100 MB
- **Disk**: Varies based on recording length (48kHz * 16-bit * 2 channels = ~172 KB/s)

## License

Remember to keep the GPL-3.0 license headers in all source files:

```swift
//  Copyright (C) 2025
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
```

## Getting Help

- **Issues**: Report bugs on GitHub Issues
- **Discussions**: Join GitHub Discussions for questions
- **Documentation**: Check the README.md

---

Happy coding! 🎙️
