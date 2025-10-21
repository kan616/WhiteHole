//
//  AudioCaptureApp.swift
//  AudioCapture
//
//  A simple macOS system audio recorder using ScreenCaptureKit
//  Copyright (C) 2025
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//

import SwiftUI

@main
struct AudioCaptureApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
