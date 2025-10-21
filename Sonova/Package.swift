// swift-tools-version: 5.9
//
//  Package.swift
//  Sonova
//
//  Swift Package configuration
//  Copyright (C) 2025
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//

import PackageDescription

let package = Package(
    name: "Sonova",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Sonova",
            targets: ["Sonova"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Sonova",
            dependencies: []
        )
    ]
)
