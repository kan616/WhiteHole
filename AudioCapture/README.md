# AudioCapture

![Platform: macOS](https://img.shields.io/badge/platform-macOS%2012.3%2B-blue)
![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-green)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)

**AudioCapture** is a simple, elegant macOS application for recording system audio. Built with SwiftUI and ScreenCaptureKit, it provides a clean, minimal interface for capturing system audio without requiring any external drivers.

## Features

- **Driver-Free**: No external audio drivers required - uses native macOS ScreenCaptureKit
- **Simple & Minimal**: Clean, intuitive interface focused on essential functionality
- **Real-time Monitoring**: Visual audio level meter during recording
- **High Quality**: Records in 48kHz, 16-bit stereo WAV format
- **Zero Latency**: Direct system audio capture with no additional processing delay
- **Auto-Save**: Recordings are automatically saved to `~/Music/AudioCapture Recordings/`

## System Requirements

- macOS 12.3 (Monterey) or later
- Screen Recording permission (granted on first use)

## Installation

### Option 1: Build from Source

1. Clone this repository
2. Open `AudioCapture.xcodeproj` in Xcode
3. Build and run (⌘R)

```bash
git clone https://github.com/yourusername/AudioCapture.git
cd AudioCapture
open AudioCapture.xcodeproj
```

### Option 2: Download Pre-built App

*Coming soon - Binary releases will be available once the app is ready for distribution*

## Usage

1. **Launch AudioCapture**
2. **Click "Start Recording"**
   - On first launch, macOS will request Screen Recording permission
   - Go to System Settings > Privacy & Security > Screen Recording
   - Enable permission for AudioCapture
3. **Record your system audio**
   - The timer shows recording duration
   - The level meter displays real-time audio levels
4. **Click "Stop Recording"**
   - Recording is automatically saved
   - Click "Show in Finder" to locate your recording

## How It Works

AudioCapture uses Apple's **ScreenCaptureKit** framework, introduced in macOS 12.3. This modern API allows applications to capture system audio directly without requiring kernel extensions or third-party audio drivers.

The audio capture pipeline:
```
System Audio → ScreenCaptureKit → Audio Processing → WAV File
```

### Why ScreenCaptureKit?

- ✅ No driver installation required
- ✅ Works with all system audio sources
- ✅ Native macOS integration
- ✅ Secure and sandboxed
- ✅ No kernel extensions

Similar to how OBS Studio captures audio on macOS.

## Technical Details

- **Framework**: ScreenCaptureKit, AVFoundation, SwiftUI
- **Language**: Swift 5.9+
- **Architecture**: MVVM pattern
- **Audio Format**: WAV (Linear PCM, 48kHz, 16-bit, Stereo)
- **Minimum Target**: macOS 12.3

## Project Structure

```
AudioCapture/
├── Sources/
│   ├── AudioCapture/
│   │   └── AudioCaptureApp.swift      # App entry point
│   ├── Views/
│   │   └── ContentView.swift          # Main UI
│   └── Services/
│       ├── SystemAudioRecorder.swift  # Recording engine
│       └── AudioFileWriter.swift      # File writing
├── LICENSE                             # GPL-3.0 License
└── README.md                          # This file
```

## Permissions

AudioCapture requires **Screen Recording** permission to capture system audio. This is a macOS system requirement for using ScreenCaptureKit.

To grant permission:
1. Open **System Settings**
2. Go to **Privacy & Security** > **Screen Recording**
3. Enable the toggle for **AudioCapture**
4. Restart the app

## Roadmap

Future enhancements planned:

- [ ] Multiple audio format support (MP3, AAC, FLAC)
- [ ] Custom output directory selection
- [ ] Keyboard shortcuts
- [ ] Menu bar mode
- [ ] Recording history
- [ ] Audio trimming/editing
- [ ] Application-specific audio capture
- [ ] Scheduled recordings

## License

AudioCapture is licensed under the **GNU General Public License v3.0**.

This means:
- ✅ Free to use, modify, and distribute
- ✅ Source code must remain open
- ✅ Derivative works must use GPL-3.0
- ✅ Commercial use is allowed
- ✅ You must include the license and copyright notice

See [LICENSE](LICENSE) for full details.

### Why GPL-3.0?

We chose GPL-3.0 to keep AudioCapture free and open-source forever. If you build upon this project, your improvements must also be shared with the community.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

### Development Setup

1. Fork the repository
2. Clone your fork
3. Create a feature branch
4. Make your changes
5. Submit a pull request

Please ensure your code:
- Follows Swift style guidelines
- Includes appropriate comments
- Maintains the GPL-3.0 license headers

## Acknowledgments

- Built with Apple's ScreenCaptureKit framework
- Inspired by OBS Studio's macOS audio capture implementation
- UI design inspired by modern macOS aesthetics

## Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/AudioCapture/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/AudioCapture/discussions)

## FAQ

### Why does it need Screen Recording permission?

ScreenCaptureKit is Apple's unified framework for capturing both screen and audio content. Even though AudioCapture only records audio, the permission is still required by macOS.

### Can it record audio from specific applications?

Not in the current version, but this is planned for a future update. ScreenCaptureKit supports per-application audio capture.

### What audio formats are supported?

Currently, only WAV format is supported. MP3, AAC, and FLAC support is planned for future releases.

### Does it work on older macOS versions?

No, AudioCapture requires macOS 12.3 or later because it uses ScreenCaptureKit, which was introduced in that version.

### Can I use this in my commercial product?

Yes, under GPL-3.0, but your entire product must also be GPL-3.0 licensed and open-source. For proprietary/closed-source use, you would need different licensing.

## Related Projects

If you're looking for alternatives or complementary tools:

- **BlackHole** - Virtual audio driver for macOS (driver-based approach)
- **OBS Studio** - Broadcasting and recording software with audio capture
- **Audio Hijack** - Commercial audio recording application

---

**Made with ❤️ for the macOS community**

*AudioCapture - Simple, elegant system audio recording*
