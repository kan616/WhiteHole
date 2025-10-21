//
//  ContentView.swift
//  AudioCapture
//
//  Main user interface for AudioCapture
//  Copyright (C) 2025
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var recorder = SystemAudioRecorder()
    @State private var showingSaveAlert = false
    @State private var savedFileURL: URL?

    var body: some View {
        VStack(spacing: 24) {
            // App Title
            Text("AudioCapture")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            // Status Indicator
            HStack(spacing: 12) {
                Circle()
                    .fill(recorder.isRecording ? Color.red : Color.gray.opacity(0.3))
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(recorder.isRecording ? Color.red.opacity(0.3) : Color.clear, lineWidth: 4)
                            .scaleEffect(recorder.isRecording ? 1.3 : 1.0)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: recorder.isRecording)
                    )

                Text(recorder.isRecording ? "Recording..." : "Ready")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }

            // Recording Duration
            if recorder.isRecording {
                Text(formatDuration(recorder.recordingDuration))
                    .font(.system(size: 48, weight: .light, design: .monospaced))
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())
            }

            // Audio Level Meter
            if recorder.isRecording {
                AudioLevelMeterView(level: recorder.audioLevel)
                    .frame(height: 8)
                    .padding(.horizontal, 40)
            }

            // Record Button
            Button(action: {
                Task {
                    await toggleRecording()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: recorder.isRecording ? "stop.circle.fill" : "record.circle")
                        .font(.system(size: 20))

                    Text(recorder.isRecording ? "Stop Recording" : "Start Recording")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(width: 200, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(recorder.isRecording ? Color.red : Color.blue)
                )
            }
            .buttonStyle(.plain)
            .shadow(color: (recorder.isRecording ? Color.red : Color.blue).opacity(0.3), radius: 8, y: 4)

            // Error Message
            if let error = recorder.errorMessage {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Info Text
            if !recorder.isRecording {
                Text("System audio will be captured and saved to\n~/Music/AudioCapture Recordings/")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
        }
        .padding(32)
        .frame(width: 400)
        .alert("Recording Saved", isPresented: $showingSaveAlert) {
            Button("Show in Finder") {
                if let url = savedFileURL {
                    NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
                }
            }
            Button("OK", role: .cancel) {}
        } message: {
            if let url = savedFileURL {
                Text("Recording saved to:\n\(url.lastPathComponent)")
            }
        }
    }

    private func toggleRecording() async {
        if recorder.isRecording {
            // Stop recording
            do {
                savedFileURL = try await recorder.stopRecording()
                showingSaveAlert = true
            } catch {
                print("Error stopping recording: \(error)")
            }
        } else {
            // Start recording
            do {
                try await recorder.startRecording()
            } catch {
                print("Error starting recording: \(error)")
            }
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

// MARK: - Audio Level Meter View

struct AudioLevelMeterView: View {
    let level: Float

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))

                // Level Indicator
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [.green, .yellow, .orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(min(level * 2, 1.0)))
                    .animation(.easeInOut(duration: 0.1), value: level)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
