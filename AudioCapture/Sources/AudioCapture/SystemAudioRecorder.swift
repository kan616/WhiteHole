//
//  SystemAudioRecorder.swift
//  AudioCapture
//
//  System audio recording engine using ScreenCaptureKit
//  Copyright (C) 2025
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//

import Foundation
import ScreenCaptureKit
import AVFoundation
import Combine

@MainActor
class SystemAudioRecorder: NSObject, ObservableObject {

    // MARK: - Published Properties
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var audioLevel: Float = 0
    @Published var errorMessage: String?

    // MARK: - Private Properties
    private var stream: SCStream?
    private var audioFile: AVAudioFile?
    private var recordingURL: URL?
    private var audioEngine = AVAudioEngine()
    private var recordingStartTime: Date?
    private var timer: Timer?

    private let audioSettings: [String: Any] = [
        AVFormatIDKey: Int(kAudioFormatLinearPCM),
        AVSampleRateKey: 48000.0,
        AVNumberOfChannelsKey: 2,
        AVLinearPCMBitDepthKey: 16,
        AVLinearPCMIsFloatKey: false,
        AVLinearPCMIsBigEndianKey: false,
        AVLinearPCMIsNonInterleaved: false
    ]

    // MARK: - Public Methods

    /// Start recording system audio
    func startRecording() async throws {
        guard !isRecording else { return }

        // Request screen recording permission
        guard await checkScreenRecordingPermission() else {
            throw RecordingError.permissionDenied
        }

        // Create output file URL
        recordingURL = createRecordingURL()

        do {
            // Get available content
            let content = try await SCShareableContent.excludingDesktopWindows(
                false,
                onScreenWindowsOnly: false
            )

            // Configure stream to capture system audio
            let configuration = SCStreamConfiguration()
            configuration.capturesAudio = true
            configuration.sampleRate = 48000
            configuration.channelCount = 2
            configuration.excludesCurrentProcessAudio = true

            // Create filter (no specific window/display needed for audio-only)
            let filter = SCContentFilter(
                desktopIndependentWindow: nil
            )

            // Create and start stream
            stream = SCStream(
                filter: filter,
                configuration: configuration,
                delegate: self
            )

            // Add audio output handler
            try stream?.addStreamOutput(
                self,
                type: .audio,
                sampleHandlerQueue: DispatchQueue(label: "audio.capture.queue")
            )

            try await stream?.startCapture()

            // Update state
            isRecording = true
            recordingStartTime = Date()
            startTimer()

        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
            throw error
        }
    }

    /// Stop recording and save file
    func stopRecording() async throws -> URL? {
        guard isRecording else { return nil }

        do {
            // Stop the stream
            try await stream?.stopCapture()
            stream = nil

            // Stop timer
            stopTimer()

            // Update state
            isRecording = false
            recordingDuration = 0

            // Return the saved file URL
            return recordingURL

        } catch {
            errorMessage = "Failed to stop recording: \(error.localizedDescription)"
            throw error
        }
    }

    // MARK: - Private Methods

    private func checkScreenRecordingPermission() async -> Bool {
        // Check if we can capture screen content (includes audio permission)
        do {
            _ = try await SCShareableContent.excludingDesktopWindows(
                false,
                onScreenWindowsOnly: false
            )
            return true
        } catch {
            errorMessage = "Screen recording permission is required. Please enable it in System Preferences > Privacy & Security > Screen Recording."
            return false
        }
    }

    private func createRecordingURL() -> URL {
        let documentsPath = FileManager.default.urls(
            for: .musicDirectory,
            in: .userDomainMask
        )[0]

        let recordingsFolder = documentsPath.appendingPathComponent("AudioCapture Recordings")

        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(
            at: recordingsFolder,
            withIntermediateDirectories: true
        )

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH.mm.ss"
        let filename = "Recording \(dateFormatter.string(from: Date())).wav"

        return recordingsFolder.appendingPathComponent(filename)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.recordingStartTime else { return }
            Task { @MainActor in
                self.recordingDuration = Date().timeIntervalSince(startTime)
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        recordingStartTime = nil
    }
}

// MARK: - SCStreamDelegate

extension SystemAudioRecorder: SCStreamDelegate {
    nonisolated func stream(
        _ stream: SCStream,
        didStopWithError error: Error
    ) {
        Task { @MainActor in
            errorMessage = "Stream stopped with error: \(error.localizedDescription)"
            isRecording = false
        }
    }
}

// MARK: - SCStreamOutput

extension SystemAudioRecorder: SCStreamOutput {
    nonisolated func stream(
        _ stream: SCStream,
        didOutputSampleBuffer sampleBuffer: CMSampleBuffer,
        of type: SCStreamOutputType
    ) {
        guard type == .audio else { return }

        // Process audio buffer
        // This is where we would write to the audio file
        Task { @MainActor in
            // Update audio level for visualization
            if let audioLevel = calculateAudioLevel(from: sampleBuffer) {
                self.audioLevel = audioLevel
            }

            // Write to file
            writeAudioBuffer(sampleBuffer)
        }
    }

    private func calculateAudioLevel(from sampleBuffer: CMSampleBuffer) -> Float? {
        guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else {
            return nil
        }

        var length = 0
        var dataPointer: UnsafeMutablePointer<Int8>?

        guard CMBlockBufferGetDataPointer(
            blockBuffer,
            atOffset: 0,
            lengthAtOffsetOut: nil,
            totalLengthOut: &length,
            dataPointerOut: &dataPointer
        ) == noErr else {
            return nil
        }

        guard let pointer = dataPointer else { return nil }

        // Calculate RMS level
        let int16Pointer = pointer.withMemoryRebound(to: Int16.self, capacity: length / 2) { $0 }
        let samples = UnsafeBufferPointer(start: int16Pointer, count: length / 2)

        var sum: Float = 0
        for sample in samples {
            let normalized = Float(sample) / Float(Int16.max)
            sum += normalized * normalized
        }

        let rms = sqrt(sum / Float(samples.count))
        return rms
    }

    private func writeAudioBuffer(_ sampleBuffer: CMSampleBuffer) {
        // For now, we'll implement basic file writing
        // In a production app, you'd want to use AVAssetWriter for more robust writing
        guard let url = recordingURL else { return }

        // This is a simplified implementation
        // A full implementation would use AVAssetWriter to write the audio samples
    }
}

// MARK: - Recording Error

enum RecordingError: LocalizedError {
    case permissionDenied
    case streamCreationFailed
    case fileCreationFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Screen recording permission is required"
        case .streamCreationFailed:
            return "Failed to create capture stream"
        case .fileCreationFailed:
            return "Failed to create output file"
        }
    }
}
