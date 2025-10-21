//
//  AudioFileWriter.swift
//  Sonova
//
//  Audio file writing service using AVAssetWriter
//  Copyright (C) 2025
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//

import Foundation
import AVFoundation

class AudioFileWriter {
    private var assetWriter: AVAssetWriter?
    private var assetWriterInput: AVAssetWriterInput?
    private var outputURL: URL
    private var isWriting = false

    init(outputURL: URL) {
        self.outputURL = outputURL
    }

    func startWriting() throws {
        // Create asset writer
        assetWriter = try AVAssetWriter(url: outputURL, fileType: .wav)

        // Configure audio settings
        let audioSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 48000,
            AVNumberOfChannelsKey: 2,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]

        // Create asset writer input
        assetWriterInput = AVAssetWriterInput(
            mediaType: .audio,
            outputSettings: audioSettings
        )

        assetWriterInput?.expectsMediaDataInRealTime = true

        guard let input = assetWriterInput,
              let writer = assetWriter,
              writer.canAdd(input) else {
            throw AudioFileWriterError.cannotAddInput
        }

        writer.add(input)

        guard writer.startWriting() else {
            throw AudioFileWriterError.cannotStartWriting
        }

        writer.startSession(atSourceTime: .zero)
        isWriting = true
    }

    func write(sampleBuffer: CMSampleBuffer) {
        guard isWriting,
              let input = assetWriterInput,
              input.isReadyForMoreMediaData else {
            return
        }

        input.append(sampleBuffer)
    }

    func finishWriting() async throws {
        guard isWriting else { return }

        assetWriterInput?.markAsFinished()

        await assetWriter?.finishWriting()

        isWriting = false
    }
}

enum AudioFileWriterError: LocalizedError {
    case cannotAddInput
    case cannotStartWriting

    var errorDescription: String? {
        switch self {
        case .cannotAddInput:
            return "Cannot add audio input to asset writer"
        case .cannotStartWriting:
            return "Cannot start asset writer"
        }
    }
}
